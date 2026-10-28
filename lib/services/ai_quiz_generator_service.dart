import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../models/course_model.dart';

class AiQuizGeneratorService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _configuredModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.8-flash',
  );
  static const String _fallbackModel = 'gemini-3.5-flash-lite';
  static const int _requestTimeoutSeconds = int.fromEnvironment(
    'GEMINI_TIMEOUT_SECONDS',
    defaultValue: 90,
  );

  String? lastErrorMessage;

  Future<List<CourseQuiz>?> generateQuizzesFromDocument(
    Uint8List documentBytes,
    String moduleTitle, {
    int numQuizzes = 1,
    int numQuestions = 5,
    String mimeType = 'application/pdf',
    String? extractedDocumentText,
    String? sourceFileName,
    Set<CourseQuestionType> questionTypes = const {
      CourseQuestionType.multipleChoice,
    },
    Map<CourseQuestionType, int>? questionTypeCounts,
  }) async {
    lastErrorMessage = null;

    _log(
      'START module="$moduleTitle" file=${sourceFileName ?? 'unnamed'} '
      'bytes=${documentBytes.length} '
      'mime=$mimeType quizzes=$numQuizzes questionsPerQuiz=$numQuestions '
      'types=${questionTypes.map((type) => type.storageValue).join(',')} '
      'sourceMode=${extractedDocumentText == null ? 'binary' : 'extracted-text'}',
    );

    if (_apiKey.isEmpty) {
      lastErrorMessage =
          'Gemini is not configured in this app session. Stop Flutter and run '
          'scripts/run_chrome.ps1, then try again. Hot restart is not enough.';
      _log(
        'STOP: GEMINI_API_KEY is missing. Relaunch with '
        '--dart-define-from-file=.gemini.local.json.',
      );
      return null;
    }

    final selectedTypes = questionTypes.isEmpty
        ? const {CourseQuestionType.multipleChoice}
        : Set<CourseQuestionType>.from(questionTypes);
    final exactTypeCounts = <CourseQuestionType, int>{
      for (final entry in (questionTypeCounts ?? const {}).entries)
        if (selectedTypes.contains(entry.key) && entry.value > 0)
          entry.key: entry.value,
    };
    final typeNames = selectedTypes.map((type) => type.storageValue).join(', ');
    final distributionRule = exactTypeCounts.isEmpty
        ? 'Distribute the selected types as evenly as possible. When the question count permits, include every selected type in every quiz.'
        : 'In each quiz, use exactly these question counts:\n'
              '${exactTypeCounts.entries.map((entry) => '- ${entry.key.storageValue}: ${entry.value}').join('\n')}\n'
              'Do not add, remove, or substitute question types.';
    final typeRules = selectedTypes
        .map((type) {
          return switch (type) {
            CourseQuestionType.multipleChoice =>
              '- multipleChoice: provide exactly 4 options, a correctIndex from 0 to 3, and an empty correctAnswers array.',
            CourseQuestionType.trueFalse =>
              '- trueFalse: provide options ["True", "False"], a correctIndex of 0 for True or 1 for False, and an empty correctAnswers array.',
            CourseQuestionType.identification =>
              '- identification: provide an empty options array, correctIndex 0, and correctAnswers containing the expected short answer plus any acceptable equivalents.',
            CourseQuestionType.enumeration =>
              '- enumeration: provide an empty options array, correctIndex 0, and correctAnswers containing every required item as a separate string.',
          };
        })
        .join('\n');

    final prompt =
        '''
You are an expert chemistry teacher. Analyze the attached module and generate exactly $numQuizzes quiz(zes).
Each quiz must have exactly $numQuestions questions based only on the module's content.
Use only these selected question types: $typeNames.
$distributionRule
$typeRules

Respond only with a valid JSON array. Do not wrap it in Markdown code blocks.
Each object in the array must match this structure exactly:
{
  "title": "A short, descriptive title for the quiz",
  "directions": "Clear directions covering the generated question types",
  "questions": [
    {
      "type": "one selected type value",
      "question": "The question text",
      "options": ["Only used for multipleChoice and trueFalse"],
      "correctIndex": 0,
      "correctAnswers": ["Only used for identification and enumeration"],
      "explanation": "A brief explanation of why this is correct."
    }
  ]
}
''';

    final content = extractedDocumentText == null
        ? [
            Content.multi([
              TextPart(prompt),
              DataPart(mimeType, documentBytes),
            ]),
          ]
        : [
            Content.text(
              '$prompt\n\n'
              'The following plain text was extracted from '
              '${sourceFileName ?? 'the attached module'}. Base every '
              'question only on this extracted content.\n\n'
              '--- BEGIN MODULE CONTENT ---\n'
              '$extractedDocumentText\n'
              '--- END MODULE CONTENT ---',
            ),
          ];
    final modelNames = <String>{
      _configuredModel,
      _fallbackModel,
    }.where((name) => name.trim().isNotEmpty).toList();
    _log(
      'Prepared request. Models=${modelNames.join(' -> ')} '
      'timeout=${_requestTimeoutSeconds}s apiKeyConfigured=true',
    );

    Object? lastModelError;
    for (var index = 0; index < modelNames.length; index++) {
      final modelName = modelNames[index];
      final requestWatch = Stopwatch()..start();
      Timer? heartbeat;

      try {
        _log(
          'REQUEST ${index + 1}/${modelNames.length}: sending to $modelName...',
        );
        heartbeat = Timer.periodic(const Duration(seconds: 10), (_) {
          _log(
            'WAITING for $modelName: '
            '${requestWatch.elapsed.inSeconds}s elapsed...',
          );
        });
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        final response = await model
            .generateContent(content)
            .timeout(const Duration(seconds: _requestTimeoutSeconds));
        final jsonString = response.text;
        _log(
          'RESPONSE from $modelName after '
          '${requestWatch.elapsedMilliseconds}ms; '
          'characters=${jsonString?.length ?? 0}',
        );

        if (jsonString == null || jsonString.trim().isEmpty) {
          throw const FormatException('Gemini returned an empty response.');
        }

        _log('PARSING Gemini JSON response...');
        late final List<CourseQuiz> quizzes;
        try {
          quizzes = _parseQuizzesJson(jsonString, moduleTitle, selectedTypes);
          if (exactTypeCounts.isNotEmpty) {
            if (quizzes.length != numQuizzes) {
              throw FormatException(
                'Expected $numQuizzes quiz(zes), but AI returned ${quizzes.length}.',
              );
            }
            for (final quiz in quizzes) {
              for (final entry in exactTypeCounts.entries) {
                final actual = quiz.questions
                    .where((question) => question.type == entry.key)
                    .length;
                if (actual != entry.value) {
                  throw FormatException(
                    'Expected ${entry.value} ${entry.key.label} item(s), but AI returned $actual.',
                  );
                }
              }
            }
          }
        } catch (error) {
          final compactResponse = jsonString.replaceAll(RegExp(r'\s+'), ' ');
          final preview = compactResponse.length > 600
              ? '${compactResponse.substring(0, 600)}...'
              : compactResponse;
          _log('PARSE ERROR RESPONSE PREVIEW: $preview');
          rethrow;
        }
        final generatedQuestionCount = quizzes.fold<int>(
          0,
          (total, quiz) => total + quiz.questions.length,
        );
        _log(
          'SUCCESS: parsed ${quizzes.length} quiz(zes), '
          '$generatedQuestionCount total questions in '
          '${requestWatch.elapsedMilliseconds}ms.',
        );
        return quizzes;
      } catch (error, stackTrace) {
        lastModelError = error;
        final hasFallback = index < modelNames.length - 1;
        _log(
          'ERROR from $modelName after ${requestWatch.elapsedMilliseconds}ms: '
          '${error.runtimeType}: $error',
        );

        if (hasFallback && _isModelAvailabilityError(error)) {
          _log(
            'FALLBACK: $modelName is unavailable; trying '
            '${modelNames[index + 1]}.',
          );
          continue;
        }

        _recordFailure(error, stackTrace);
        return null;
      } finally {
        heartbeat?.cancel();
        requestWatch.stop();
      }
    }

    if (lastModelError != null) {
      _recordFailure(lastModelError, StackTrace.current);
    }
    return null;
  }

  List<CourseQuiz> _parseQuizzesJson(
    String jsonString,
    String defaultTitle,
    Set<CourseQuestionType> allowedTypes,
  ) {
    var cleanJson = jsonString.trim();
    if (cleanJson.startsWith('```json')) {
      cleanJson = cleanJson.substring(7);
    } else if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.substring(3);
    }
    if (cleanJson.endsWith('```')) {
      cleanJson = cleanJson.substring(0, cleanJson.length - 3);
    }

    final decoded = jsonDecode(cleanJson.trim());
    if (decoded is! List || decoded.isEmpty) {
      throw const FormatException('Gemini did not return a quiz array.');
    }

    _log('JSON root contains ${decoded.length} quiz object(s).');
    return decoded.map<CourseQuiz>((quizData) {
      if (quizData is! Map<String, dynamic>) {
        throw const FormatException('A generated quiz has an invalid format.');
      }

      final rawQuestions = quizData['questions'];
      if (rawQuestions is! List || rawQuestions.isEmpty) {
        throw const FormatException('A generated quiz has no questions.');
      }

      final questions = rawQuestions.map<CourseQuestion>((rawQuestion) {
        if (rawQuestion is! Map<String, dynamic>) {
          throw const FormatException(
            'A generated question has an invalid format.',
          );
        }

        final type = rawQuestion['type'] == null && allowedTypes.length == 1
            ? allowedTypes.first
            : _parseQuestionType(rawQuestion['type']);
        if (!allowedTypes.contains(type)) {
          throw FormatException(
            'Gemini returned the unselected question type ${type.label}.',
          );
        }
        final question = rawQuestion['question']?.toString().trim() ?? '';
        if (question.isEmpty) {
          throw const FormatException(
            'A generated question has no question text.',
          );
        }

        var options = <String>[];
        var correctIndex = 0;
        var correctAnswers = <String>[];

        switch (type) {
          case CourseQuestionType.multipleChoice:
            options = _stringList(rawQuestion['options']);
            final rawCorrectIndex = rawQuestion['correctIndex'];
            correctIndex = rawCorrectIndex is num
                ? rawCorrectIndex.toInt()
                : -1;
            if (options.length != 4 ||
                correctIndex < 0 ||
                correctIndex >= options.length) {
              throw const FormatException(
                'A generated multiple-choice question has invalid choices.',
              );
            }
          case CourseQuestionType.trueFalse:
            options = const ['True', 'False'];
            final rawCorrectIndex = rawQuestion['correctIndex'];
            if (rawCorrectIndex is num) {
              correctIndex = rawCorrectIndex.toInt();
            } else {
              final answer = rawQuestion['correctAnswer']
                  ?.toString()
                  .trim()
                  .toLowerCase();
              correctIndex = answer == 'true'
                  ? 0
                  : answer == 'false'
                  ? 1
                  : -1;
            }
            if (correctIndex < 0 || correctIndex > 1) {
              throw const FormatException(
                'A generated true-or-false question has an invalid answer.',
              );
            }
          case CourseQuestionType.identification:
          case CourseQuestionType.enumeration:
            correctAnswers = _stringList(rawQuestion['correctAnswers']);
            if (correctAnswers.isEmpty) {
              final singleAnswer = rawQuestion['correctAnswer']
                  ?.toString()
                  .trim();
              if (singleAnswer != null && singleAnswer.isNotEmpty) {
                correctAnswers = [singleAnswer];
              }
            }
            if (correctAnswers.isEmpty) {
              throw const FormatException(
                'A generated written-answer question has no correct answer.',
              );
            }
        }

        return CourseQuestion(
          id: const Uuid().v4(),
          question: question,
          type: type,
          options: options,
          correctIndex: correctIndex,
          correctAnswers: correctAnswers,
          explanation: rawQuestion['explanation'] as String? ?? '',
        );
      }).toList();
      if (allowedTypes.length > 1) {
        questions.sort((a, b) => a.type.index.compareTo(b.type.index));
      }

      _log(
        'Parsed quiz "${quizData['title'] ?? defaultTitle}" with '
        '${questions.length} question(s): '
        '${questions.map((question) => question.type.storageValue).join(',')}',
      );

      return CourseQuiz(
        id: const Uuid().v4(),
        title: quizData['title'] as String? ?? 'Quiz: $defaultTitle',
        directions: _defaultDirections(allowedTypes),
        questions: questions,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  CourseQuestionType _parseQuestionType(Object? value) {
    final normalized = value?.toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );
    return switch (normalized) {
      'multiplechoice' => CourseQuestionType.multipleChoice,
      'truefalse' => CourseQuestionType.trueFalse,
      'identification' => CourseQuestionType.identification,
      'enumeration' => CourseQuestionType.enumeration,
      _ => throw const FormatException(
        'Gemini returned an unknown question type.',
      ),
    };
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _defaultDirections(Set<CourseQuestionType> types) {
    final orderedTypes = CourseQuestionType.values
        .where(types.contains)
        .toList();
    if (orderedTypes.length == 1) {
      return orderedTypes.first.direction;
    }

    return [
      'This quiz contains multiple question types. Follow the appropriate direction for each item:',
      ...orderedTypes.map((type) => '${type.label}: ${type.direction}'),
    ].join('\n');
  }

  bool _isModelAvailabilityError(Object error) {
    final message = error.toString().toLowerCase();
    final mentionsModel =
        message.contains('model') || message.contains('generatecontent');
    final unavailable =
        message.contains('not found') ||
        message.contains('not supported') ||
        message.contains('unavailable') ||
        message.contains('404') ||
        message.contains('503');
    return mentionsModel && unavailable;
  }

  void _recordFailure(Object error, StackTrace stackTrace) {
    final message = error.toString().toLowerCase();
    if (error is TimeoutException || message.contains('timed out')) {
      lastErrorMessage =
          'AI quiz generation timed out after $_requestTimeoutSeconds seconds. '
          'Try fewer questions or a smaller document.';
    } else if (_isModelAvailabilityError(error)) {
      lastErrorMessage =
          'The Gemini quiz model is temporarily unavailable. Please try again.';
    } else if (message.contains('api key') ||
        message.contains('invalid_api_key') ||
        message.contains('401')) {
      lastErrorMessage =
          'The Gemini API key is invalid. Update the app configuration and try again.';
    } else if (message.contains('prepayment') ||
        message.contains('credits are depleted') ||
        message.contains('payment required') ||
        message.contains('402')) {
      lastErrorMessage =
          'Gemini credits are depleted. Add credits in Google AI Studio Billing, then try again.';
    } else if (message.contains('quota') || message.contains('429')) {
      lastErrorMessage =
          'The Gemini quota has been reached. Please wait and try again.';
    } else if (error is FormatException || error is TypeError) {
      lastErrorMessage =
          'Gemini returned invalid quiz data. Please generate the quiz again.';
    } else {
      lastErrorMessage = 'AI quiz generation failed. Please try again.';
    }

    _log('FAILED: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _log(String message) {
    debugPrint('[AI QUIZ][${DateTime.now().toIso8601String()}] $message');
  }
}

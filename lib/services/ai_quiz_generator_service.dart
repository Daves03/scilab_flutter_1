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

  String? lastErrorMessage;

  Future<List<CourseQuiz>?> generateQuizzesFromPdf(
    Uint8List pdfBytes,
    String moduleTitle, {
    int numQuizzes = 1,
    int numQuestions = 5,
    String mimeType = 'application/pdf',
  }) async {
    lastErrorMessage = null;

    if (_apiKey.isEmpty) {
      lastErrorMessage =
          'AI quiz generation is not configured in this app build. Rebuild the app with the Gemini configuration, then try again.';
      return null;
    }

    final prompt =
        '''
You are an expert chemistry teacher. Analyze the attached module and generate exactly $numQuizzes multiple-choice quiz(zes).
Each quiz must have exactly $numQuestions questions based only on the module's content.
Respond only with a valid JSON array. Do not wrap it in Markdown code blocks.
Each object in the array must match this structure exactly:
{
  "title": "A short, descriptive title for the quiz",
  "questions": [
    {
      "question": "The question text",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctIndex": 0,
      "explanation": "A brief explanation of why this is correct."
    }
  ]
}
''';

    final content = [
      Content.multi([TextPart(prompt), DataPart(mimeType, pdfBytes)]),
    ];
    final modelNames = <String>{
      _configuredModel,
      _fallbackModel,
    }.where((name) => name.trim().isNotEmpty).toList();

    Object? lastModelError;
    for (var index = 0; index < modelNames.length; index++) {
      final modelName = modelNames[index];

      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );
        final response = await model.generateContent(content);
        final jsonString = response.text;

        if (jsonString == null || jsonString.trim().isEmpty) {
          throw const FormatException('Gemini returned an empty response.');
        }

        return _parseQuizzesJson(jsonString, moduleTitle);
      } catch (error, stackTrace) {
        lastModelError = error;
        final hasFallback = index < modelNames.length - 1;

        if (hasFallback && _isModelAvailabilityError(error)) {
          debugPrint(
            'Gemini model $modelName is unavailable; trying ${modelNames[index + 1]}.',
          );
          continue;
        }

        _recordFailure(error, stackTrace);
        return null;
      }
    }

    if (lastModelError != null) {
      _recordFailure(lastModelError, StackTrace.current);
    }
    return null;
  }

  List<CourseQuiz> _parseQuizzesJson(String jsonString, String defaultTitle) {
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

        final options = rawQuestion['options'];
        final correctIndex = rawQuestion['correctIndex'];
        if (options is! List ||
            options.length != 4 ||
            correctIndex is! int ||
            correctIndex < 0 ||
            correctIndex >= options.length) {
          throw const FormatException(
            'A generated question has invalid answer choices.',
          );
        }

        return CourseQuestion(
          id: const Uuid().v4(),
          question: rawQuestion['question'] as String,
          options: options.map((option) => option.toString()).toList(),
          correctIndex: correctIndex,
          explanation: rawQuestion['explanation'] as String? ?? '',
        );
      }).toList();

      return CourseQuiz(
        id: const Uuid().v4(),
        title: quizData['title'] as String? ?? 'Quiz: $defaultTitle',
        questions: questions,
        createdAt: DateTime.now(),
      );
    }).toList();
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
    if (_isModelAvailabilityError(error)) {
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

    debugPrint('Failed to generate quiz: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

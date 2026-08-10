import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/course_model.dart';
import 'package:uuid/uuid.dart';

class AiQuizGeneratorService {
  // TODO: Replace with your actual Gemini API Key from Google AI Studio
  static const String _apiKey = 'ai api here';

  Future<List<CourseQuiz>?> generateQuizzesFromPdf(Uint8List pdfBytes, String moduleTitle, {int numQuizzes = 1, int numQuestions = 5}) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.isEmpty) {
      print('AI API Key not set. Returning dummy quiz.');
      // Return a dummy quiz if the API key isn't set so the UI doesn't break
      return [_generateDummyQuiz(moduleTitle)];
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt = '''
      You are an expert chemistry teacher. Analyze the attached PDF module and generate exactly \$numQuizzes multiple choice quiz(zes).
      Each quiz must have exactly \$numQuestions questions based on the module's content.
      Respond ONLY with a valid JSON array of quizzes. Do not wrap it in markdown code blocks.
      Each object in the array must match this structure exactly:
      {
        "title": "A short, descriptive title for the quiz",
        "questions": [
          {
            "question": "The question text",
            "options": ["Option A", "Option B", "Option C", "Option D"],
            "correctIndex": 0, // The integer index of the correct option (0-3)
            "explanation": "Brief explanation of why this is correct."
          }
        ]
      }
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('application/pdf', pdfBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final jsonString = response.text;
      
      if (jsonString != null && jsonString.isNotEmpty) {
        return _parseQuizzesJson(jsonString, moduleTitle);
      }
      
      return null;
    } catch (e) {
      print('Failed to generate quiz: $e');
      return null;
    }
  }

  List<CourseQuiz> _parseQuizzesJson(String jsonString, String defaultTitle) {
    try {
      // Sometimes Gemini returns JSON wrapped in markdown even when told not to. Clean it.
      var cleanJson = jsonString.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      
      final List<dynamic> decodedList = jsonDecode(cleanJson);
      
      return decodedList.map((quizData) {
        final qList = quizData['questions'] as List<dynamic>;
        final questions = qList.map((q) {
          return CourseQuestion(
            id: const Uuid().v4(),
            question: q['question'] as String,
            options: List<String>.from(q['options']),
            correctIndex: q['correctIndex'] as int,
            explanation: q['explanation'] as String? ?? '',
          );
        }).toList();

        return CourseQuiz(
          id: const Uuid().v4(),
          title: quizData['title'] as String? ?? 'Quiz: $defaultTitle',
          questions: questions,
        );
      }).toList();
    } catch (e) {
      print('Error parsing JSON from AI: $e');
      // Fallback
      return [_generateDummyQuiz(defaultTitle)];
    }
  }

  CourseQuiz _generateDummyQuiz(String title) {
    return CourseQuiz(
      id: const Uuid().v4(),
      title: 'Auto-Generated Quiz: $title',
      questions: [
        CourseQuestion(
          id: const Uuid().v4(),
          question: 'What is the main topic of this module?',
          options: ['Option A', 'Option B', 'Option C', 'Option D'],
          correctIndex: 0,
          explanation: 'This is a placeholder explanation.',
        ),
      ],
    );
  }
}

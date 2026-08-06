import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  QuizQuestion copyWith({
    String? text,
    List<String>? options,
    int? correctIndex,
  }) {
    return QuizQuestion(
      text: text ?? this.text,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
    );
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> data) => QuizQuestion(
        text: (data['text'] as String?) ?? '',
        options: List<String>.from(data['options'] ?? const []),
        correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
      };
}

/// Mirrors one document in the Firestore `quizzes` collection.
class Quiz {
  final String id;
  final String title;
  final String moduleId; // optional link back to a ModuleAttachment.id
  final String createdByUid;
  final List<QuizQuestion> questions;
  final DateTime? createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.moduleId,
    required this.createdByUid,
    required this.questions,
    this.createdAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return Quiz(
      id: id,
      title: (data['title'] as String?) ?? '',
      moduleId: (data['moduleId'] as String?) ?? '',
      createdByUid: (data['createdByUid'] as String?) ?? '',
      questions: ((data['questions'] as List<dynamic>?) ?? const [])
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q as Map)))
          .toList(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'moduleId': moduleId,
        'createdByUid': createdByUid,
        'questions': questions.map((q) => q.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// A student's submitted answers for one [Quiz]. Mirrors one document
/// in the Firestore `quiz_attempts` collection.
class QuizAttempt {
  final String id;
  final String quizId;
  final String studentId;
  final List<int> selectedAnswers;
  final int score;
  final DateTime? submittedAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.selectedAnswers,
    required this.score,
    this.submittedAt,
  });

  factory QuizAttempt.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['submittedAt'];
    return QuizAttempt(
      id: id,
      quizId: (data['quizId'] as String?) ?? '',
      studentId: (data['studentId'] as String?) ?? '',
      selectedAnswers: List<int>.from(data['selectedAnswers'] ?? const []),
      score: (data['score'] as num?)?.toInt() ?? 0,
      submittedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'quizId': quizId,
        'studentId': studentId,
        'selectedAnswers': selectedAnswers,
        'score': score,
        'submittedAt': FieldValue.serverTimestamp(),
      };
}

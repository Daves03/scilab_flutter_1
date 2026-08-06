import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CourseModule {
  final String id;
  final String title;
  final String description;
  final String fileType; // 'pdf', 'video', 'doc', 'ppt'
  final String uploadedByName;
  final DateTime? uploadedAt;
  final int fileSizeBytes;
  final String url;
  final String storagePath;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.fileType,
    required this.uploadedByName,
    required this.uploadedAt,
    required this.fileSizeBytes,
    required this.url,
    required this.storagePath,
  });

  String get friendlySize {
    if (fileSizeBytes <= 0) { return ''; }
    const kb = 1024;
    const mb = kb * 1024;
    if (fileSizeBytes >= mb) return '${(fileSizeBytes / mb).toStringAsFixed(1)} MB';
    return '${(fileSizeBytes / kb).ceil()} KB';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formatted like the old mock data ("Jul 10, 2025"), so widgets that
  /// displayed uploadedDate as a string need no further changes.
  String get uploadedDateLabel {
    if (uploadedAt == null) { return ''; }
    final d = uploadedAt!;
    return '${_months[d.month - 1]} ${d.day}, ${d.year}';
  }

  factory CourseModule.fromMap(Map<String, dynamic> data) {
    final ts = data['uploadedAt'];
    return CourseModule(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      fileType: data['fileType']?.toString() ?? '',
      uploadedByName: data['uploadedByName']?.toString() ?? 'Teacher',
      uploadedAt: ts is Timestamp ? ts.toDate() : null,
      fileSizeBytes: (data['fileSizeBytes'] as num?)?.toInt() ?? 0,
      url: data['url']?.toString() ?? '',
      storagePath: data['storagePath']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'fileType': fileType,
        'uploadedByName': uploadedByName,
        // Arrays can't hold FieldValue.serverTimestamp(), so this is
        // set client-side when the module is created.
        'uploadedAt': uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : null,
        'fileSizeBytes': fileSizeBytes,
        'url': url,
        'storagePath': storagePath,
      };
}

class CourseQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  CourseQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory CourseQuestion.fromMap(Map<String, dynamic> data) => CourseQuestion(
        id: data['id']?.toString() ?? '',
        question: data['question']?.toString() ?? '',
        options: (data['options'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: data['explanation']?.toString() ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class CourseQuiz {
  final String id;
  final String title;
  final List<CourseQuestion> questions;
  final DateTime? createdAt;

  CourseQuiz({
    required this.id,
    required this.title,
    required this.questions,
    this.createdAt,
  });

  int get totalQuestions => questions.length;

  factory CourseQuiz.fromMap(Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return CourseQuiz(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      questions: ((data['questions'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (q) => CourseQuestion.fromMap(
              Map<String, dynamic>.from(q as Map),
            ),
          )
          .toList(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'questions': questions.map((q) => q.toMap()).toList(),
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };
}

/// Mirrors one document in the Firestore `courses` collection. Modules
/// and quizzes live as array fields on the same doc rather than
/// subcollections — course content is small enough that a single
/// read/write per course is simpler than N+1 subcollection queries.
class Course {
  final String id;
  final String title;
  final String subject;
  final String grade; // 'Grade 9' / 'Grade 10' — matches UserRole.label
  final String teacherUid;
  final String teacherName;
  final int accentColorValue;
  final String iconName;
  final List<String> sections;
  final List<CourseModule> modules;
  final List<CourseQuiz> quizzes;
  final DateTime? createdAt;

  /// Set client-side after loading — how much of this course's quizzes
  /// the current student has completed. Not stored on the shared course
  /// doc itself, since progress is per-student, not per-course.
  double progress = 0.0;

  Color get accentColor => Color(accentColorValue);
  String get teacher => teacherName;

  Course({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.teacherUid,
    required this.teacherName,
    required this.accentColorValue,
    required this.iconName,
    required this.sections,
    required this.modules,
    required this.quizzes,
    this.createdAt,
  });

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return Course(
      id: id,
      title: data['title']?.toString() ?? '',
      subject: data['subject']?.toString() ?? '',
      grade: data['grade']?.toString() ?? '',
      teacherUid: data['teacherUid']?.toString() ?? '',
      teacherName: data['teacherName']?.toString() ?? 'Teacher',
      accentColorValue:
          (data['accentColorValue'] as num?)?.toInt() ?? 0xFF00D4FF,
      iconName: data['iconName']?.toString() ?? 'science',
      sections: (data['sections'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      modules: ((data['modules'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (m) => CourseModule.fromMap(
              Map<String, dynamic>.from(m as Map),
            ),
          )
          .toList(),
      quizzes: ((data['quizzes'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (q) => CourseQuiz.fromMap(
              Map<String, dynamic>.from(q as Map),
            ),
          )
          .toList(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'subject': subject,
        'grade': grade,
        'teacherUid': teacherUid,
        'teacherName': teacherName,
        'accentColorValue': accentColorValue,
        'iconName': iconName,
        'sections': sections,
        'modules': modules.map((m) => m.toMap()).toList(),
        'quizzes': quizzes.map((q) => q.toMap()).toList(),
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      };
}

/// A student's submitted answers for one quiz within one course.
/// Mirrors one document in the Firestore `quiz_attempts` collection.
class QuizAttempt {
  final String id;
  final String courseId;
  final String quizId;
  final String quizTitle;
  final String studentId;
  final List<int> selectedAnswers;
  final int score;
  final int totalQuestions;
  final DateTime? submittedAt;

  QuizAttempt({
    required this.id,
    required this.courseId,
    required this.quizId,
    required this.quizTitle,
    required this.studentId,
    required this.selectedAnswers,
    required this.score,
    required this.totalQuestions,
    this.submittedAt,
  });

  factory QuizAttempt.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['submittedAt'];
    return QuizAttempt(
      id: id,
      courseId: (data['courseId'] as String?) ?? '',
      quizId: (data['quizId'] as String?) ?? '',
      quizTitle: (data['quizTitle'] as String?) ?? '',
      studentId: (data['studentId'] as String?) ?? '',
      selectedAnswers: List<int>.from(data['selectedAnswers'] ?? const []),
      score: (data['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (data['totalQuestions'] as num?)?.toInt() ?? 0,
      submittedAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'courseId': courseId,
        'quizId': quizId,
        'quizTitle': quizTitle,
        'studentId': studentId,
        'selectedAnswers': selectedAnswers,
        'score': score,
        'totalQuestions': totalQuestions,
        'submittedAt': FieldValue.serverTimestamp(),
      };
}


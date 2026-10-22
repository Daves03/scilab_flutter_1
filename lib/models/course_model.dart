import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CourseModule {
  final String id;
  final String title;
  final String description;
  final String fileType; // 'pdf', 'video', 'doc', 'ppt'
  final String uploadedByUid;
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
    this.uploadedByUid = '',
    required this.uploadedByName,
    required this.uploadedAt,
    required this.fileSizeBytes,
    required this.url,
    required this.storagePath,
  });

  String get friendlySize {
    if (fileSizeBytes <= 0) {
      return '';
    }
    const kb = 1024;
    const mb = kb * 1024;
    if (fileSizeBytes >= mb)
      return '${(fileSizeBytes / mb).toStringAsFixed(1)} MB';
    return '${(fileSizeBytes / kb).ceil()} KB';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Formatted like the old mock data ("Jul 10, 2025"), so widgets that
  /// displayed uploadedDate as a string need no further changes.
  String get uploadedDateLabel {
    if (uploadedAt == null) {
      return '';
    }
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
      uploadedByUid: data['uploadedByUid']?.toString() ?? '',
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
    if (uploadedByUid.isNotEmpty) 'uploadedByUid': uploadedByUid,
    'uploadedByName': uploadedByName,
    // Arrays can't hold FieldValue.serverTimestamp(), so this is
    // set client-side when the module is created.
    'uploadedAt': uploadedAt != null ? Timestamp.fromDate(uploadedAt!) : null,
    'fileSizeBytes': fileSizeBytes,
    'url': url,
    'storagePath': storagePath,
  };

  CourseModule copyWith({String? uploadedByUid, String? uploadedByName}) {
    return CourseModule(
      id: id,
      title: title,
      description: description,
      fileType: fileType,
      uploadedByUid: uploadedByUid ?? this.uploadedByUid,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      uploadedAt: uploadedAt,
      fileSizeBytes: fileSizeBytes,
      url: url,
      storagePath: storagePath,
    );
  }
}

enum CourseQuestionType {
  multipleChoice,
  trueFalse,
  identification,
  enumeration;

  String get storageValue => switch (this) {
    CourseQuestionType.multipleChoice => 'multipleChoice',
    CourseQuestionType.trueFalse => 'trueFalse',
    CourseQuestionType.identification => 'identification',
    CourseQuestionType.enumeration => 'enumeration',
  };

  String get label => switch (this) {
    CourseQuestionType.multipleChoice => 'Multiple Choice',
    CourseQuestionType.trueFalse => 'True or False',
    CourseQuestionType.identification => 'Identification',
    CourseQuestionType.enumeration => 'Enumeration',
  };

  static CourseQuestionType fromStorageValue(Object? value) {
    return CourseQuestionType.values.firstWhere(
      (type) => type.storageValue == value?.toString(),
      orElse: () => CourseQuestionType.multipleChoice,
    );
  }
}

class CourseQuestion {
  final String id;
  final String question;
  final CourseQuestionType type;
  final List<String> options;
  final int correctIndex;
  final List<String> correctAnswers;
  final String explanation;

  CourseQuestion({
    required this.id,
    required this.question,
    this.type = CourseQuestionType.multipleChoice,
    required this.options,
    required this.correctIndex,
    this.correctAnswers = const [],
    required this.explanation,
  });

  factory CourseQuestion.fromMap(Map<String, dynamic> data) => CourseQuestion(
    id: data['id']?.toString() ?? '',
    question: data['question']?.toString() ?? '',
    type: CourseQuestionType.fromStorageValue(data['type']),
    options:
        (data['options'] as List?)?.map((e) => e.toString()).toList() ??
        const [],
    correctIndex: (data['correctIndex'] as num?)?.toInt() ?? 0,
    correctAnswers:
        (data['correctAnswers'] as List?)
            ?.map((answer) => answer.toString())
            .toList() ??
        const [],
    explanation: data['explanation']?.toString() ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'type': type.storageValue,
    'options': options,
    'correctIndex': correctIndex,
    'correctAnswers': correctAnswers,
    'explanation': explanation,
  };
}

class CourseQuiz {
  final String id;
  final String title;
  final String directions;
  final List<CourseQuestion> questions;
  final DateTime? createdAt;
  final DateTime? dueDate;

  CourseQuiz({
    required this.id,
    required this.title,
    this.directions = '',
    required this.questions,
    this.createdAt,
    this.dueDate,
  });

  int get totalQuestions => questions.length;

  String get dueDateLabel {
    if (dueDate == null) return '';
    final d = dueDate!;
    int hour = d.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    final min = d.minute.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final year = d.year.toString().substring(2);
    return '$month/$day/$year at $hour:$min $ampm';
  }

  factory CourseQuiz.fromMap(Map<String, dynamic> data) {
    final ts = data['createdAt'];
    return CourseQuiz(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      directions: data['directions']?.toString() ?? '',
      questions: ((data['questions'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (q) => CourseQuestion.fromMap(Map<String, dynamic>.from(q as Map)),
          )
          .toList(),
      createdAt: ts is Timestamp ? ts.toDate() : null,
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'directions': directions,
    'questions': questions.map((q) => q.toMap()).toList(),
    'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
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
    required List<String> sections,
    required List<CourseModule> modules,
    required List<CourseQuiz> quizzes,
    this.createdAt,
  }) : sections = List<String>.of(sections),
       modules = List<CourseModule>.of(modules),
       quizzes = List<CourseQuiz>.of(quizzes);

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final currentSections = data['sections'];
    final legacySections = data['assignedSections'];
    final sectionSource = currentSections is List && currentSections.isNotEmpty
        ? currentSections
        : legacySections;
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
      sections: sectionSource is List
          ? sectionSource.map((e) => e.toString()).toList()
          : const [],
      modules: ((data['modules'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => CourseModule.fromMap(Map<String, dynamic>.from(m as Map)))
          .toList(),
      quizzes: ((data['quizzes'] as List<dynamic>?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((q) => CourseQuiz.fromMap(Map<String, dynamic>.from(q as Map)))
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

  Course copyWith({String? teacherName, List<CourseModule>? modules}) {
    final updated = Course(
      id: id,
      title: title,
      subject: subject,
      grade: grade,
      teacherUid: teacherUid,
      teacherName: teacherName ?? this.teacherName,
      accentColorValue: accentColorValue,
      iconName: iconName,
      sections: sections,
      modules: modules ?? this.modules,
      quizzes: quizzes,
      createdAt: createdAt,
    );
    updated.progress = progress;
    return updated;
  }
}

/// A student's submitted answers for one quiz within one course.
/// Mirrors one document in the Firestore `quiz_attempts` collection.
class QuizAttempt {
  final String id;
  final String courseId;
  final String quizId;
  final String quizTitle;
  final String studentId;
  final String? studentName;
  final List<int> selectedAnswers;
  final Map<String, List<String>> textAnswers;
  final int score;
  final int totalQuestions;
  final DateTime? submittedAt;

  QuizAttempt({
    required this.id,
    required this.courseId,
    required this.quizId,
    required this.quizTitle,
    required this.studentId,
    this.studentName,
    required this.selectedAnswers,
    this.textAnswers = const {},
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
      studentName: data['studentName'] as String?,
      selectedAnswers: List<int>.from(data['selectedAnswers'] ?? const []),
      textAnswers: ((data['textAnswers'] as Map?) ?? const {}).map(
        (key, value) => MapEntry(
          key.toString(),
          (value as List?)?.map((answer) => answer.toString()).toList() ??
              const <String>[],
        ),
      ),
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
    if (studentName != null) 'studentName': studentName,
    'selectedAnswers': selectedAnswers,
    'textAnswers': textAnswers,
    'score': score,
    'totalQuestions': totalQuestions,
    'submittedAt': FieldValue.serverTimestamp(),
  };
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _quizCollection = 'quizzes';
  static const _attemptCollection = 'quiz_attempts';

  Stream<List<Quiz>> getQuizzesStream() {
    return _db
        .collection(_quizCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Quiz.fromMap(d.id, d.data())).toList());
  }

  Future<void> createQuiz(Quiz quiz) => _db.collection(_quizCollection).add(quiz.toMap());

  Future<void> updateQuiz(Quiz quiz) =>
      _db.collection(_quizCollection).doc(quiz.id).update(quiz.toMap());

  Future<void> deleteQuiz(String quizId) =>
      _db.collection(_quizCollection).doc(quizId).delete();

  Future<void> submitAttempt(QuizAttempt attempt) =>
      _db.collection(_attemptCollection).add(attempt.toMap());

  Stream<List<QuizAttempt>> getAttemptsForStudent(String studentId) {
    return _db
        .collection(_attemptCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList());
  }

  Stream<List<QuizAttempt>> getAttemptsForQuiz(String quizId) {
    return _db
        .collection(_attemptCollection)
        .where('quizId', isEqualTo: quizId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList());
  }
}

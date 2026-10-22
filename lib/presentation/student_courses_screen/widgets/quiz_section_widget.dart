import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/auth_service.dart';
import './quiz_leave_confirmation_dialog.dart';

class QuizSectionWidget extends StatefulWidget {
  final Course course;
  final String? initialQuizId;
  final ValueChanged<bool>? onUnsavedQuizChanged;

  const QuizSectionWidget({
    required this.course,
    this.initialQuizId,
    this.onUnsavedQuizChanged,
    super.key,
  });

  @override
  State<QuizSectionWidget> createState() => _QuizSectionWidgetState();
}

class _QuizSectionWidgetState extends State<QuizSectionWidget> {
  // Track which quiz is being taken (null = list view)
  CourseQuiz? _activeQuiz;
  // Track answers: questionId -> selectedIndex
  final Map<String, int> _selectedAnswers = {};
  // Track written answers: questionId -> one or more response fields.
  final Map<String, List<String>> _textAnswers = {};
  // Track if quiz was submitted
  bool _quizSubmitted = false;
  Stream<QuerySnapshot>? _attemptsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthService>().currentUser;
      if (user != null && mounted) {
        setState(() {
          _attemptsStream = FirebaseFirestore.instance
              .collection('quiz_attempts')
              .where('courseId', isEqualTo: widget.course.id)
              .where('studentId', isEqualTo: user.id)
              .snapshots();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant QuizSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeQuiz = _activeQuiz;
    if (activeQuiz == null) return;

    CourseQuiz? updatedQuiz;
    for (final quiz in widget.course.quizzes) {
      if (quiz.id == activeQuiz.id) {
        updatedQuiz = quiz;
        break;
      }
    }

    if (updatedQuiz == null) {
      _activeQuiz = null;
      _selectedAnswers.clear();
      _textAnswers.clear();
      _quizSubmitted = false;
      widget.onUnsavedQuizChanged?.call(false);
    } else {
      _activeQuiz = updatedQuiz;
    }
  }

  void _startQuiz(CourseQuiz quiz) {
    setState(() {
      _activeQuiz = quiz;
      _selectedAnswers.clear();
      _textAnswers.clear();
      _quizSubmitted = false;
    });
    widget.onUnsavedQuizChanged?.call(true);
  }

  void _selectAnswer(String questionId, int index) {
    if (_quizSubmitted) return;
    setState(() => _selectedAnswers[questionId] = index);
  }

  void _updateTextAnswer(String questionId, int index, String value) {
    if (_quizSubmitted) return;
    setState(() {
      final answers = _textAnswers.putIfAbsent(questionId, () => []);
      while (answers.length <= index) {
        answers.add('');
      }
      answers[index] = value;
    });
  }

  Future<void> _submitQuiz() async {
    if (_activeQuiz == null) return;
    int score = 0;
    for (final q in _activeQuiz!.questions) {
      if (_isQuestionCorrect(q)) score++;
    }

    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      final attempt = QuizAttempt(
        id: FirebaseFirestore.instance.collection('quiz_attempts').doc().id,
        courseId: widget.course.id,
        quizId: _activeQuiz!.id,
        quizTitle: _activeQuiz!.title,
        studentId: user.id,
        studentName: user.name,
        selectedAnswers: _activeQuiz!.questions
            .map((q) => _selectedAnswers[q.id] ?? -1)
            .toList(),
        textAnswers: {
          for (final entry in _textAnswers.entries)
            entry.key: List<String>.from(entry.value),
        },
        score: score,
        totalQuestions: _activeQuiz!.questions.length,
      );

      await FirebaseFirestore.instance
          .collection('quiz_attempts')
          .doc(attempt.id)
          .set(attempt.toMap());
    }

    setState(() {
      _quizSubmitted = true;
    });
    widget.onUnsavedQuizChanged?.call(false);
  }

  void _viewQuiz(
    CourseQuiz quiz,
    Map<String, int> answers,
    Map<String, List<String>> textAnswers,
  ) {
    setState(() {
      _activeQuiz = quiz;
      _selectedAnswers.clear();
      _selectedAnswers.addAll(answers);
      _textAnswers.clear();
      _textAnswers.addAll(
        textAnswers.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
      _quizSubmitted = true;
    });
    widget.onUnsavedQuizChanged?.call(false);
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF142240)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _effectiveAccentColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'help_outline',
                      color: _effectiveAccentColor,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Submit Quiz?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to submit your answers? You cannot change them after submission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF8BA3C0)
                        : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E3A5F)
                                : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _submitQuiz();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _effectiveAccentColor,
                          foregroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0A1628)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _exitQuiz() {
    setState(() {
      _activeQuiz = null;
      _selectedAnswers.clear();
      _textAnswers.clear();
      _quizSubmitted = false;
    });
    widget.onUnsavedQuizChanged?.call(false);
  }

  Future<void> _requestExitQuiz() async {
    if (_quizSubmitted) {
      _exitQuiz();
      return;
    }
    final shouldLeave = await showQuizLeaveConfirmationDialog(context);
    if (!mounted || !shouldLeave) return;
    _exitQuiz();
  }

  int get _answeredCount {
    final quiz = _activeQuiz;
    if (quiz == null) return 0;
    return quiz.questions.where((question) {
      if (question.type == CourseQuestionType.multipleChoice ||
          question.type == CourseQuestionType.trueFalse) {
        return _selectedAnswers.containsKey(question.id);
      }
      final answers = _textAnswers[question.id] ?? const <String>[];
      final requiredCount = question.type == CourseQuestionType.enumeration
          ? question.correctAnswers.length
          : 1;
      return requiredCount > 0 &&
          answers.length >= requiredCount &&
          answers
              .take(requiredCount)
              .every((answer) => answer.trim().isNotEmpty);
    }).length;
  }

  int get _totalQuestions => _activeQuiz?.questions.length ?? 0;

  bool _isQuestionCorrect(CourseQuestion question) {
    if (question.type == CourseQuestionType.multipleChoice ||
        question.type == CourseQuestionType.trueFalse) {
      return _selectedAnswers[question.id] == question.correctIndex;
    }
    return _writtenAnswerIsCorrect(
      question,
      _textAnswers[question.id] ?? const <String>[],
    );
  }

  Color get _effectiveAccentColor {
    return widget.course.accentColor == const Color(0xFF00D4FF)
        ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF00D4FF)
              : const Color(0xFF1565C0))
        : widget.course.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeQuiz != null) {
      return _buildQuizView();
    }
    return _buildQuizList();
  }

  // ── Quiz list ──────────────────────────────────────────────────────────────

  Widget _buildQuizList() {
    final quizzes = List<CourseQuiz>.from(widget.course.quizzes);
    final requestedQuizId = widget.initialQuizId;
    if (requestedQuizId != null) {
      final requestedIndex = quizzes.indexWhere(
        (quiz) => quiz.id == requestedQuizId,
      );
      if (requestedIndex > 0) {
        quizzes.insert(0, quizzes.removeAt(requestedIndex));
      }
    }
    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No quizzes available yet.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8BA3C0)
                  : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _attemptsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final completedQuizzes = <String, int>{};
        final savedAnswers = <String, Map<String, int>>{};
        final savedTextAnswers = <String, Map<String, List<String>>>{};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final attempt = QuizAttempt.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
            completedQuizzes[attempt.quizId] = attempt.score;

            final quiz = quizzes.firstWhere(
              (q) => q.id == attempt.quizId,
              orElse: () => CourseQuiz(id: '', title: '', questions: []),
            );
            if (quiz.id.isNotEmpty) {
              Map<String, int> answersMap = {};
              for (int i = 0; i < attempt.selectedAnswers.length; i++) {
                if (i < quiz.questions.length) {
                  answersMap[quiz.questions[i].id] = attempt.selectedAnswers[i];
                }
              }
              savedAnswers[attempt.quizId] = answersMap;
              savedTextAnswers[attempt.quizId] = attempt.textAnswers;
            }
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final isDone = completedQuizzes.containsKey(quiz.id);
            final score = completedQuizzes[quiz.id];
            final pct = isDone ? (score! / quiz.totalQuestions) : null;
            final isMissed =
                !isDone &&
                quiz.dueDate != null &&
                quiz.dueDate!.isBefore(DateTime.now());

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuizCard(
                quiz: quiz,
                isDone: isDone,
                isMissed: isMissed,
                score: score,
                percentage: pct,
                accentColor: _effectiveAccentColor,
                isHighlighted: quiz.id == requestedQuizId,
                onStart: () => _startQuiz(quiz),
                onRetake: () => _viewQuiz(
                  quiz,
                  savedAnswers[quiz.id] ?? {},
                  savedTextAnswers[quiz.id] ?? {},
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Active quiz view ───────────────────────────────────────────────────────

  Widget _buildQuizView() {
    final quiz = _activeQuiz!;
    return Column(
      children: [
        // Quiz header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              GestureDetector(
                onTap: _requestExitQuiz,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF142240)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF8BA3C0)
                          : Colors.grey.shade700,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quiz.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!_quizSubmitted)
                Text(
                  '$_answeredCount/$_totalQuestions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _effectiveAccentColor,
                  ),
                ),
            ],
          ),
        ),
        // Progress bar
        if (!_quizSubmitted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: _totalQuestions > 0
                    ? _answeredCount / _totalQuestions
                    : 0,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _effectiveAccentColor,
                ),
                minHeight: 4,
              ),
            ),
          ),
        if (quiz.directions.trim().isNotEmpty)
          _buildDirectionsPanel(quiz.directions),
        // Score result banner
        if (_quizSubmitted) _buildScoreBanner(quiz),
        // Questions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              final q = quiz.questions[index];
              return _QuestionCard(
                question: q,
                questionNumber: index + 1,
                selectedIndex: _selectedAnswers[q.id],
                textAnswers: _textAnswers[q.id] ?? const <String>[],
                isSubmitted: _quizSubmitted,
                accentColor: _effectiveAccentColor,
                onSelect: (i) => _selectAnswer(q.id, i),
                onTextChanged: (i, value) => _updateTextAnswer(q.id, i, value),
              );
            },
          ),
        ),
        // Submit button
        if (!_quizSubmitted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answeredCount == _totalQuestions
                    ? _confirmSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _effectiveAccentColor,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0A1628)
                      : Colors.white,
                  disabledBackgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E3A5F)
                      : Colors.grey.shade200,
                  disabledForegroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF5A7A9A)
                      : Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _answeredCount == _totalQuestions
                      ? 'Submit Quiz'
                      : 'Answer all questions to submit',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        if (_quizSubmitted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exitQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF142240)
                      : Colors.white,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade300,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Back to Quizzes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDirectionsPanel(String directions) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _effectiveAccentColor.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _effectiveAccentColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Directions',
            style: TextStyle(
              color: _effectiveAccentColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            directions,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFD5E2F0)
                  : const Color(0xFF344054),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBanner(CourseQuiz quiz) {
    int score = 0;
    for (final q in quiz.questions) {
      if (_isQuestionCorrect(q)) score++;
    }
    final total = quiz.totalQuestions;
    final pct = score / total;
    final Color color;
    final String message;
    final String icon;
    if (pct >= 0.8) {
      color = const Color(0xFF00FF88);
      message = 'Excellent work!';
      icon = 'emoji_events';
    } else if (pct >= 0.6) {
      color = const Color(0xFFFFB800);
      message = 'Good job!';
      icon = 'thumb_up';
    } else {
      color = const Color(0xFFFF4757);
      message = 'Keep practicing!';
      icon = 'refresh';
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(iconName: icon, color: color, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Score: $score / $total  (${(pct * 100).toInt()}%)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF8BA3C0)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz card ─────────────────────────────────────────────────────────────────

class _QuizCard extends StatelessWidget {
  final CourseQuiz quiz;
  final bool isDone;
  final bool isMissed;
  final int? score;
  final double? percentage;
  final Color accentColor;
  final bool isHighlighted;
  final VoidCallback onStart;
  final VoidCallback onRetake;

  const _QuizCard({
    required this.quiz,
    required this.isDone,
    required this.isMissed,
    required this.score,
    required this.percentage,
    required this.accentColor,
    required this.isHighlighted,
    required this.onStart,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isDone
        ? (percentage! >= 0.8
              ? const Color(0xFF00FF88)
              : percentage! >= 0.6
              ? const Color(0xFFFFB800)
              : const Color(0xFFFF4757))
        : isMissed
        ? const Color(0xFFFF4757) // Red for missed
        : accentColor;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: isHighlighted ? accentColor : statusColor.withAlpha(40),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: accentColor.withAlpha(35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: isDone
                        ? 'check_circle'
                        : (isMissed ? 'lock' : 'quiz'),
                    color: statusColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quiz.totalQuestions} questions${quiz.dueDate != null ? (isMissed ? ' • Missed: ${quiz.dueDateLabel}' : ' • Due: ${quiz.dueDateLabel}') : ' • No Due Date'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF8BA3C0)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Text(
                    '${score!}/${quiz.totalQuestions}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
            ],
          ),
          if (isDone) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3A5F)
                    : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4,
              ),
            ),
          ],
          if (quiz.directions.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withAlpha(45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Directions',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.directions,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFB7C9DD)
                          : Colors.grey.shade700,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDone ? onRetake : (isMissed ? null : onStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A2D4A)
                          : Colors.grey.shade200)
                    : accentColor,
                disabledBackgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A2D4A)
                    : Colors.grey.shade200,
                foregroundColor: isDone
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87)
                    : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0A1628)
                          : Colors.white),
                disabledForegroundColor:
                    Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF5A7A9A)
                    : Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isDone
                      ? BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E3A5F)
                              : Colors.grey.shade300,
                        )
                      : BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: Text(
                isDone ? 'View Results' : (isMissed ? 'Missed' : 'Start Quiz'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Question card ─────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final CourseQuestion question;
  final int questionNumber;
  final int? selectedIndex;
  final List<String> textAnswers;
  final bool isSubmitted;
  final Color accentColor;
  final ValueChanged<int> onSelect;
  final void Function(int, String) onTextChanged;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.selectedIndex,
    required this.textAnswers,
    required this.isSubmitted,
    required this.accentColor,
    required this.onSelect,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F1E35)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        question.type.label,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (question.type == CourseQuestionType.multipleChoice ||
              question.type == CourseQuestionType.trueFalse)
            ...List.generate(question.options.length, (i) {
              return _OptionTile(
                label: question.options[i],
                index: i,
                isSelected: selectedIndex == i,
                isSubmitted: isSubmitted,
                accentColor: accentColor,
                onTap: () => onSelect(i),
              );
            })
          else
            ..._buildWrittenAnswerFields(context),
        ],
      ),
    );
  }

  List<Widget> _buildWrittenAnswerFields(BuildContext context) {
    final isEnumeration = question.type == CourseQuestionType.enumeration;
    final hideCorrectAnswer =
        question.type == CourseQuestionType.identification ||
        question.type == CourseQuestionType.enumeration;
    final fieldCount = isEnumeration
        ? (question.correctAnswers.isEmpty ? 1 : question.correctAnswers.length)
        : 1;
    final responseIsCorrect = _writtenAnswerIsCorrect(question, textAnswers);

    return [
      ...List.generate(fieldCount, (index) {
        final initialValue = index < textAnswers.length
            ? textAnswers[index]
            : '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: TextFormField(
            key: ValueKey('${question.id}_answer_$index'),
            initialValue: initialValue,
            enabled: !isSubmitted,
            onChanged: (value) => onTextChanged(index, value),
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              labelText: isEnumeration ? 'Answer ${index + 1}' : 'Your answer',
              hintText: isEnumeration
                  ? 'Enter item ${index + 1}'
                  : 'Type your answer',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF142240)
                  : Colors.grey.shade50,
              labelStyle: const TextStyle(
                color: Color(0xFF8BA3C0),
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A4668)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2A4668)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: responseIsCorrect
                      ? const Color(0xFF00C875)
                      : const Color(0xFFFF4757),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        );
      }),
      if (isSubmitted)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 3),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color:
                (responseIsCorrect
                        ? const Color(0xFF00C875)
                        : const Color(0xFFFF4757))
                    .withAlpha(18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  (responseIsCorrect
                          ? const Color(0xFF00C875)
                          : const Color(0xFFFF4757))
                      .withAlpha(80),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                responseIsCorrect
                    ? 'Correct'
                    : (hideCorrectAnswer ? 'WRONG' : 'Correct answer'),
                style: TextStyle(
                  color: responseIsCorrect
                      ? const Color(0xFF00C875)
                      : const Color(0xFFFF4757),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!responseIsCorrect && !hideCorrectAnswer) ...[
                const SizedBox(height: 4),
                Text(
                  question.correctAnswers.join(', '),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFFD5E2F0)
                        : Colors.grey.shade800,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
    ];
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final bool isSubmitted;
  final Color accentColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isSubmitted,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isSelected) {
      borderColor = accentColor;
      bgColor = accentColor.withAlpha(20);
      textColor = accentColor;
    } else {
      borderColor = Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E3A5F)
          : Colors.grey.shade300;
      bgColor = Colors.transparent;
      textColor = isSubmitted
          ? (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF5A7A9A)
                : Colors.grey.shade500)
          : (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF8BA3C0)
                : Colors.grey.shade700);
    }

    return GestureDetector(
      onTap: isSubmitted ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: borderColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: borderColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _normalizeWrittenAnswer(String answer) {
  return answer.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _writtenAnswerIsCorrect(
  CourseQuestion question,
  List<String> studentAnswers,
) {
  final expected = question.correctAnswers
      .map(_normalizeWrittenAnswer)
      .where((answer) => answer.isNotEmpty)
      .toList();
  final actual = studentAnswers
      .map(_normalizeWrittenAnswer)
      .where((answer) => answer.isNotEmpty)
      .toList();

  if (expected.isEmpty || actual.isEmpty) return false;
  if (question.type == CourseQuestionType.identification) {
    return expected.contains(actual.first);
  }

  if (expected.length != actual.length) return false;
  expected.sort();
  actual.sort();
  for (var index = 0; index < expected.length; index++) {
    if (expected[index] != actual[index]) return false;
  }
  return true;
}

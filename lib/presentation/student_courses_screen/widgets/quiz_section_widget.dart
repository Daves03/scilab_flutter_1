import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../core/app_export.dart';
import '../../../models/course_model.dart';
import '../../../services/auth_service.dart';

class QuizSectionWidget extends StatefulWidget {
  final Course course;

  const QuizSectionWidget({required this.course, super.key});

  @override
  State<QuizSectionWidget> createState() => _QuizSectionWidgetState();
}

class _QuizSectionWidgetState extends State<QuizSectionWidget> {
  // Track which quiz is being taken (null = list view)
  CourseQuiz? _activeQuiz;
  // Track answers: questionId -> selectedIndex
  final Map<String, int> _selectedAnswers = {};
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

  void _startQuiz(CourseQuiz quiz) {
    setState(() {
      _activeQuiz = quiz;
      _selectedAnswers.clear();
      _quizSubmitted = false;
    });
  }

  void _selectAnswer(String questionId, int index) {
    if (_quizSubmitted) return;
    setState(() => _selectedAnswers[questionId] = index);
  }

  Future<void> _submitQuiz() async {
    if (_activeQuiz == null) return;
    int score = 0;
    for (final q in _activeQuiz!.questions) {
      if (_selectedAnswers[q.id] == q.correctIndex) score++;
    }

    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      final attempt = QuizAttempt(
        id: FirebaseFirestore.instance.collection('quiz_attempts').doc().id,
        courseId: widget.course.id,
        quizId: _activeQuiz!.id,
        quizTitle: _activeQuiz!.title,
        studentId: user.id,
        selectedAnswers: _activeQuiz!.questions.map((q) => _selectedAnswers[q.id] ?? -1).toList(),
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
  }

  void _viewQuiz(CourseQuiz quiz, Map<String, int> answers) {
    setState(() {
      _activeQuiz = quiz;
      _selectedAnswers.clear();
      _selectedAnswers.addAll(answers);
      _quizSubmitted = true;
    });
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
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.course.accentColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'help_outline',
                      color: widget.course.accentColor,
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to submit your answers? You cannot change them after submission.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
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
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
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
                          backgroundColor: widget.course.accentColor,
                          foregroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
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
      _quizSubmitted = false;
    });
  }

  int get _answeredCount => _selectedAnswers.length;
  int get _totalQuestions => _activeQuiz?.questions.length ?? 0;

  @override
  Widget build(BuildContext context) {
    if (_activeQuiz != null) {
      return _buildQuizView();
    }
    return _buildQuizList();
  }

  // ── Quiz list ──────────────────────────────────────────────────────────────

  Widget _buildQuizList() {
    final quizzes = widget.course.quizzes;
    if (quizzes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No quizzes available yet.',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
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
        
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final attempt = QuizAttempt.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            completedQuizzes[attempt.quizId] = attempt.score;
            
            final quiz = quizzes.firstWhere((q) => q.id == attempt.quizId, orElse: () => CourseQuiz(id: '', title: '', questions: []));
            if (quiz.id.isNotEmpty) {
               Map<String, int> answersMap = {};
               for (int i = 0; i < attempt.selectedAnswers.length; i++) {
                 if (i < quiz.questions.length) {
                   answersMap[quiz.questions[i].id] = attempt.selectedAnswers[i];
                 }
               }
               savedAnswers[attempt.quizId] = answersMap;
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
            final isMissed = !isDone && quiz.dueDate != null && quiz.dueDate!.isBefore(DateTime.now());
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuizCard(
                quiz: quiz,
                isDone: isDone,
                isMissed: isMissed,
                score: score,
                percentage: pct,
                accentColor: widget.course.accentColor,
                onStart: () => _startQuiz(quiz),
                onRetake: () => _viewQuiz(quiz, savedAnswers[quiz.id] ?? {}),
              ),
            );
          },
        );
      }
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
                onTap: _exitQuiz,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
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
                    color: widget.course.accentColor,
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.course.accentColor,
                ),
                minHeight: 4,
              ),
            ),
          ),
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
                isSubmitted: _quizSubmitted,
                accentColor: widget.course.accentColor,
                onSelect: (i) => _selectAnswer(q.id, i),
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
                  backgroundColor: widget.course.accentColor,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
                  disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                  disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
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
                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
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

  Widget _buildScoreBanner(CourseQuiz quiz) {
    int score = 0;
    for (final q in quiz.questions) {
      if (_selectedAnswers[q.id] == q.correctIndex) score++;
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
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
  final VoidCallback onStart;
  final VoidCallback onRetake;

  const _QuizCard({
    required this.quiz,
    required this.isDone,
    required this.isMissed,
    required this.score,
    required this.percentage,
    required this.accentColor,
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
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: statusColor.withAlpha(40), width: 1),
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
                    iconName: isDone ? 'check_circle' : (isMissed ? 'lock' : 'quiz'),
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
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quiz.totalQuestions} questions',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
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
                backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDone ? onRetake : (isMissed ? null : onStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2D4A) : Colors.grey.shade200) : accentColor,
                disabledBackgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2D4A) : Colors.grey.shade200,
                foregroundColor: isDone
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                    : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white),
                disabledForegroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isDone
                      ? BorderSide(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300)
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
  final bool isSubmitted;
  final Color accentColor;
  final ValueChanged<int> onSelect;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.selectedIndex,
    required this.isSubmitted,
    required this.accentColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1E35) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300, width: 1),
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
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (i) {
            return _OptionTile(
              label: question.options[i],
              index: i,
              isSelected: selectedIndex == i,
              isSubmitted: isSubmitted,
              accentColor: accentColor,
              onTap: () => onSelect(i),
            );
          }),
        ],
      ),
    );
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
      borderColor = Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300;
      bgColor = Colors.transparent;
      textColor = isSubmitted ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF5A7A9A) : Colors.grey.shade500) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700);
    }

    final letters = ['A', 'B', 'C', 'D'];

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
                  letters[index],
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

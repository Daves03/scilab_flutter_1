import '../../../core/app_export.dart';
import '../../../models/course_model.dart';

class QuizSectionWidget extends StatefulWidget {
  final Course course;
  final void Function(String quizId, String quizTitle, int score, int total)?
      onQuizSubmitted;

  const QuizSectionWidget({required this.course, this.onQuizSubmitted, super.key});

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
  // Track completed quizzes: quizId -> score
  final Map<String, int> _completedQuizzes = {};

  void _startQuiz(CourseQuiz quiz) {
    setState(() {
      _activeQuiz = quiz;
      _selectedAnswers.clear();
      _quizSubmitted = false;
    });
  }

  void _selectAnswer(String questionId, int index) {
    if (_quizSubmitted) { return; }
    setState(() => _selectedAnswers[questionId] = index);
  }

  void _submitQuiz() {
    if (_activeQuiz == null) { return; }
    int score = 0;
    for (final q in _activeQuiz!.questions) {
      if (_selectedAnswers[q.id] == q.correctIndex) { score++; }
    }
    setState(() {
      _quizSubmitted = true;
      _completedQuizzes[_activeQuiz!.id] = score;
    });
    widget.onQuizSubmitted?.call(
      _activeQuiz!.id,
      _activeQuiz!.title,
      score,
      _activeQuiz!.totalQuestions,
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No quizzes available yet.',
            style: TextStyle(color: Color(0xFF8BA3C0), fontSize: 14),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final isDone = _completedQuizzes.containsKey(quiz.id);
        final score = _completedQuizzes[quiz.id];
        final pct = isDone ? (score! / quiz.totalQuestions) : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _QuizCard(
            quiz: quiz,
            isDone: isDone,
            score: score,
            percentage: pct,
            accentColor: widget.course.accentColor,
            onStart: () => _startQuiz(quiz),
            onRetake: () => _startQuiz(quiz),
          ),
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
                onTap: _exitQuiz,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF142240),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Color(0xFF8BA3C0),
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quiz.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                backgroundColor: const Color(0xFF1E3A5F),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _answeredCount == _totalQuestions
                    ? _submitQuiz
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.course.accentColor,
                  foregroundColor: const Color(0xFF0A1628),
                  disabledBackgroundColor: const Color(0xFF1E3A5F),
                  disabledForegroundColor: const Color(0xFF5A7A9A),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _exitQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF142240),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    side: const BorderSide(color: Color(0xFF1E3A5F)),
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
    final score = _completedQuizzes[quiz.id] ?? 0;
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8BA3C0),
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
  final int? score;
  final double? percentage;
  final Color accentColor;
  final VoidCallback onStart;
  final VoidCallback onRetake;

  const _QuizCard({
    required this.quiz,
    required this.isDone,
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
        : accentColor;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
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
                    iconName: isDone ? 'check_circle' : 'quiz',
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${quiz.totalQuestions} questions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8BA3C0),
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
                backgroundColor: const Color(0xFF1E3A5F),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDone ? onRetake : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF1A2D4A) : accentColor,
                foregroundColor: isDone
                    ? Colors.white
                    : const Color(0xFF0A1628),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: isDone
                      ? const BorderSide(color: Color(0xFF1E3A5F))
                      : BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
              child: Text(
                isDone ? 'Retake Quiz' : 'Start Quiz',
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
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
              isCorrect: i == question.correctIndex,
              accentColor: accentColor,
              onTap: () => onSelect(i),
            );
          }),
          // Explanation after submit
          if (isSubmitted && selectedIndex != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF142240),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomIconWidget(
                    iconName: 'info_outline',
                    color: Color(0xFF8BA3C0),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8BA3C0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  final bool isCorrect;
  final Color accentColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor;
    String? trailingIcon;

    if (isSubmitted) {
      if (isCorrect) {
        borderColor = const Color(0xFF00FF88);
        bgColor = const Color(0xFF00FF88).withAlpha(20);
        textColor = const Color(0xFF00FF88);
        trailingIcon = 'check_circle';
      } else if (isSelected && !isCorrect) {
        borderColor = const Color(0xFFFF4757);
        bgColor = const Color(0xFFFF4757).withAlpha(20);
        textColor = const Color(0xFFFF4757);
        trailingIcon = 'cancel';
      } else {
        borderColor = const Color(0xFF1E3A5F);
        bgColor = Colors.transparent;
        textColor = const Color(0xFF5A7A9A);
        trailingIcon = null;
      }
    } else if (isSelected) {
      borderColor = accentColor;
      bgColor = accentColor.withAlpha(20);
      textColor = accentColor;
      trailingIcon = null;
    } else {
      borderColor = const Color(0xFF1E3A5F);
      bgColor = Colors.transparent;
      textColor = const Color(0xFF8BA3C0);
      trailingIcon = null;
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
                  fontWeight: isSelected || (isSubmitted && isCorrect)
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              CustomIconWidget(
                iconName: trailingIcon,
                color: borderColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}



import '../../../core/app_export.dart';

class _QuizModel {
  final String title;
  final String subject;
  final int totalQuestions;
  final int? lastScore;
  final String iconName;

  const _QuizModel({
    required this.title,
    required this.subject,
    required this.totalQuestions,
    this.lastScore,
    required this.iconName,
  });
}

class RecentQuizWidget extends StatelessWidget {
  const RecentQuizWidget({super.key});

  static const List<_QuizModel> _quizzes = [
    _QuizModel(
      title: 'Chapter 1: Alkanes & Alkenes',
      subject: 'Organic Chemistry',
      totalQuestions: 10,
      lastScore: 85,
      iconName: 'quiz',
    ),
    _QuizModel(
      title: 'Acid-Base Equilibrium',
      subject: 'Physical Chemistry',
      totalQuestions: 15,
      lastScore: 72,
      iconName: 'science',
    ),
    _QuizModel(
      title: 'Thermodynamics Basics',
      subject: 'Physical Chemistry',
      totalQuestions: 12,
      lastScore: null,
      iconName: 'thermostat',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: _quizzes.map((q) => _buildQuizItem(q)).toList());
  }

  Widget _buildQuizItem(_QuizModel quiz) {
    final isAttempted = quiz.lastScore != null;
    final scoreColor = quiz.lastScore != null
        ? quiz.lastScore! >= 80
              ? const Color(0xFF00FF88)
              : quiz.lastScore! >= 60
              ? const Color(0xFFFFB800)
              : const Color(0xFFFF4757)
        : const Color(0xFF8BA3C0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF142240),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: quiz.iconName,
                color: const Color(0xFF00D4FF),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${quiz.subject} · ${quiz.totalQuestions} questions',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8BA3C0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isAttempted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: scoreColor.withAlpha(38),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: scoreColor.withAlpha(77), width: 1),
              ),
              child: Text(
                '${quiz.lastScore}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            )
          else
            StatusBadgeWidget(status: BadgeStatus.pending, label: 'New'),
        ],
      ),
    );
  }
}

import 'dart:ui';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

class _QuizResult {
  final String title;
  final String date;
  final int score;
  final int total;
  const _QuizResult(this.title, this.date, this.score, this.total);
}

class _ArExperimentResult {
  final String title;
  final String date;
  final double score;
  const _ArExperimentResult(this.title, this.date, this.score);
}

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  final List<_QuizResult> _quizzes = const [
    _QuizResult('Organic Chemistry Basics', 'Monday, Oct 12, 2026 at 10:30 AM', 8, 10),
    _QuizResult('Atomic Structure', 'Monday, Oct 05, 2026 at 02:15 PM', 9, 10),
    _QuizResult('Periodic Table', 'Monday, Sep 28, 2026 at 11:00 AM', 10, 10),
  ];

  final List<_ArExperimentResult> _arExperiments = const [
    _ArExperimentResult('Chemical Bonding AR', 'Saturday, Oct 10, 2026 at 04:45 PM', 95.0),
    _ArExperimentResult('Molecular Geometry', 'Friday, Oct 02, 2026 at 09:20 AM', 88.5),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              delay: 0,
              child: _buildOverviewCards(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              delay: 100,
              child: _buildSectionHeader('Quiz Results', 'quiz'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildAnimatedSection(
                delay: 200 + (index * 50),
                child: _buildQuizCard(_quizzes[index]),
              ),
              childCount: _quizzes.length,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              delay: 300,
              child: _buildSectionHeader('AR Experiments', 'science'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildAnimatedSection(
                delay: 400 + (index * 50),
                child: _buildArExperimentCard(_arExperiments[index]),
              ),
              childCount: _arExperiments.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(
              (delay / 800).clamp(0.0, 0.8),
              ((delay + 300) / 800).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );
        return SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: _entranceController,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0D2E3F) : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0x3300D4FF) : const Color(0xFF00D4FF).withOpacity(0.3), width: 1),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'insights',
                color: Color(0xFF00D4FF),
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Progress',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'Student Dashboard',
                  style: TextStyle(fontSize: 12, color: Color(0xFF00D4FF)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x2200D4FF),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: const Color(0x5500D4FF), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Color(0xFF00D4FF),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D4FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Avg Quiz',
              value: '90%',
              icon: 'quiz',
              color: const Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Avg AR Score',
              value: '91.7',
              icon: 'science',
              color: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomIconWidget(iconName: icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: const Color(0xFF8BA3C0),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(_QuizResult result) {
    final double percentage = result.score / result.total;
    Color scoreColor;
    if (percentage >= 0.8) {
      scoreColor = const Color(0xFF00FF88);
    } else if (percentage >= 0.6) {
      scoreColor = const Color(0xFFFFB300);
    } else {
      scoreColor = const Color(0xFFFF4757);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withAlpha(80)),
            ),
            child: Text(
              '${result.score} / ${result.total}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArExperimentCard(_ArExperimentResult result) {
    Color scoreColor;
    if (result.score >= 80) {
      scoreColor = const Color(0xFF00D4FF);
    } else if (result.score >= 60) {
      scoreColor = const Color(0xFF7C3AED);
    } else {
      scoreColor = const Color(0xFFFF4757);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scoreColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'view_in_ar',
                color: scoreColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${result.score.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../models/course_model.dart';
import '../../models/user_model.dart';

class _QuizResult {
  final String title;
  final String date;
  final int score;
  final int total;
  final DateTime timestamp;
  const _QuizResult(this.title, this.date, this.score, this.total, this.timestamp);
}

class _MissedQuizResult {
  final String title;
  final String date;
  final DateTime timestamp;
  const _MissedQuizResult(this.title, this.date, this.timestamp);
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

  bool _loading = true;
  List<_QuizResult> _quizzes = [];
  List<_MissedQuizResult> _missedQuizzes = [];
  List<_ArExperimentResult> _arExperiments = [];
  String _avgQuiz = '0%';
  String _avgAr = '0.0';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadData();
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$m ${dt.day}, ${dt.year} at $h:$min $ampm';
  }

  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final db = FirebaseFirestore.instance;
      
      // Fetch quizzes
      final qSnap = await db.collection('quiz_attempts').where('studentId', isEqualTo: user.id).get();
      List<_QuizResult> quizzes = [];
      double totalScore = 0;
      int quizCount = 0;

      for (var doc in qSnap.docs) {
         final data = doc.data();
         final s = (data['score'] as num?)?.toInt() ?? 0;
         final t = (data['totalQuestions'] as num?)?.toInt() ?? 1;
         final title = data['quizTitle'] as String? ?? 'Quiz';
         final ts = data['submittedAt'] as Timestamp?;
         final date = ts != null ? _formatDate(ts.toDate()) : 'Unknown Date';
         
         // Store actual timestamp for sorting
         final timestamp = ts?.toDate() ?? DateTime(2000);
         quizzes.add(_QuizResult(title, date, s, t, timestamp));
         if (t > 0) {
           totalScore += (s / t);
           quizCount++;
         }
      }
      // Sort quizzes descending by date
      quizzes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final avgQ = quizCount > 0 ? (totalScore / quizCount) * 100 : 0.0;

      // Fetch AR
      final arSnap = await db.collection('users').doc(user.id).collection('experiment_activity').where('completed', isEqualTo: true).get();
      List<_ArExperimentResult> ars = [];
      double totalAr = 0;
      int arCount = 0;

      for (var doc in arSnap.docs) {
         final data = doc.data();
         final title = data['experimentId'] as String? ?? 'Experiment';
         final ts = data['completedAt'] as Timestamp?;
         final date = ts != null ? _formatDate(ts.toDate()) : 'Unknown Date';
         final score = (data['score'] as num?)?.toDouble() ?? 100.0; // Mock score if missing
         ars.add(_ArExperimentResult(title, date, score));
         totalAr += score;
         arCount++;
      }
      final avgA = arCount > 0 ? (totalAr / arCount) : 0.0;

      // Sort AR by date descending if completedAt exists
      ars.sort((a, b) => b.date.compareTo(a.date)); 

      // Fetch missed quizzes
      List<_MissedQuizResult> missedQuizzes = [];
      if (user.role != null) {
        final coursesSnap = await db.collection('courses').where('grade', isEqualTo: user.role!.label).get();
        for (var doc in coursesSnap.docs) {
          final course = Course.fromMap(doc.id, doc.data());
          if (user.sections.isNotEmpty && course.sections.contains(user.sections.first)) {
            for (var q in course.quizzes) {
               final hasAttempted = qSnap.docs.any((d) => (d.data()['quizId'] as String?) == q.id);
               if (!hasAttempted && q.dueDate != null && q.dueDate!.isBefore(DateTime.now())) {
                  missedQuizzes.add(_MissedQuizResult(q.title, _formatDate(q.dueDate!), q.dueDate!));
               }
            }
          }
        }
        missedQuizzes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      if (mounted) {
        setState(() {
          _quizzes = quizzes;
          _missedQuizzes = missedQuizzes;
          _arExperiments = ars;
          _avgQuiz = '${avgQ.toStringAsFixed(0)}%';
          _avgAr = avgA.toStringAsFixed(1);
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching progress: $e');
      if (mounted) setState(() => _loading = false);
    }
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
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
        : CustomScrollView(
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
          _quizzes.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No quizzes completed yet.', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600)),
                    ),
                  ),
                )
              : SliverList(
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
              delay: 250,
              child: _buildSectionHeader('Missed Quizzes', 'warning', color: const Color(0xFFFF4757)),
            ),
          ),
          _missedQuizzes.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No missed quizzes.', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600)),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnimatedSection(
                      delay: 300 + (index * 50),
                      child: _buildMissedQuizCard(_missedQuizzes[index]),
                    ),
                    childCount: _missedQuizzes.length,
                  ),
                ),
          SliverToBoxAdapter(
            child: _buildAnimatedSection(
              delay: 300,
              child: _buildSectionHeader('AR Experiments', 'science'),
            ),
          ),
          _arExperiments.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No AR experiments completed yet.', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600)),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnimatedSection(
                      delay: 400 + (index * 50),
                      child: _buildArExperimentCard(_arExperiments[index]),
                    ),
                    childCount: _arExperiments.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
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
              value: _avgQuiz,
              icon: 'quiz',
              color: const Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Avg AR Score',
              value: _avgAr,
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

  Widget _buildSectionHeader(String title, String icon, {Color color = const Color(0xFF8BA3C0)}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
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

  Widget _buildMissedQuizCard(_MissedQuizResult result) {
    const scoreColor = Color(0xFFFF4757);
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
                  'Due: ${result.date}',
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
            child: const Text(
              'Missed',
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

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../models/course_model.dart';
import '../../services/auth_service.dart';
import '../../services/course_service.dart';
import '../../models/user_model.dart';
import '../../data/dummy_ar_experiments.dart';

class _QuizResult {
  final String title;
  final String date;
  final int score;
  final int total;
  final DateTime timestamp;
  const _QuizResult(
    this.title,
    this.date,
    this.score,
    this.total,
    this.timestamp,
  );
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
  final DateTime timestamp;
  const _ArExperimentResult(this.title, this.date, this.score, this.timestamp);
}

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({super.key});

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late final AuthService _authService;

  static const int _pageSize = 3;

  bool _loading = true;
  List<_QuizResult> _quizzes = [];
  List<_MissedQuizResult> _missedQuizzes = [];
  List<_ArExperimentResult> _arExperiments = [];
  String _avgQuiz = '0%';
  String _avgAr = '0.0';
  StreamSubscription<List<QuizAttempt>>? _quizAttemptsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _arActivitySub;
  String? _studentDataKey;
  int _dataVersion = 0;
  int _missedLoadVersion = 0;

  int _quizPage = 0;
  int _missedPage = 0;
  int _arPage = 0;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _authService = context.read<AuthService>();
    _authService.addListener(_handleStudentChanged);
    _handleStudentChanged();
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    final m = months[dt.month - 1];
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$m ${dt.day}, ${dt.year} at $h:$min $ampm';
  }

  String _studentKey(AppUser? user) {
    if (user == null) return 'signed-out';
    final sections =
        user.sections
            .map((section) => section.trim().toLowerCase())
            .where((section) => section.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return '${user.id}|${user.role?.id ?? ''}|${sections.join('|')}';
  }

  void _handleStudentChanged() {
    final key = _studentKey(_authService.currentUser);
    if (key == _studentDataKey) return;
    _studentDataKey = key;
    _subscribeToData();
  }

  void _subscribeToData() {
    final version = ++_dataVersion;
    _quizAttemptsSub?.cancel();
    _arActivitySub?.cancel();

    if (mounted) {
      setState(() {
        _loading = true;
        _quizzes = [];
        _missedQuizzes = [];
        _arExperiments = [];
        _avgQuiz = '0%';
        _avgAr = '0.0';
      });
    }

    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    _quizAttemptsSub = context
        .read<CourseService>()
        .attemptsForStudent(user.id)
        .listen(
          (attempts) {
            if (!mounted || version != _dataVersion) return;
            _applyQuizAttempts(attempts);
            _loadMissedQuizzes(
              user,
              attempts.map((attempt) => attempt.quizId).toSet(),
              version,
              ++_missedLoadVersion,
            );
          },
          onError: (Object error) {
            debugPrint('Error streaming quiz progress: $error');
            if (mounted && version == _dataVersion) {
              setState(() => _loading = false);
            }
          },
        );

    _arActivitySub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('experiment_activity')
        .snapshots()
        .listen(
          (snapshot) {
            if (!mounted || version != _dataVersion) return;
            _applyArActivity(snapshot.docs);
          },
          onError: (Object error) {
            debugPrint('Error streaming AR progress: $error');
          },
        );
  }

  void _applyQuizAttempts(List<QuizAttempt> attempts) {
    final latestByQuiz = <String, QuizAttempt>{};
    for (final attempt in attempts) {
      if (attempt.quizId.isEmpty || attempt.totalQuestions <= 0) continue;
      final current = latestByQuiz[attempt.quizId];
      final submittedAt = attempt.submittedAt ?? DateTime(2000);
      final currentSubmittedAt = current?.submittedAt ?? DateTime(2000);
      if (current == null || !submittedAt.isBefore(currentSubmittedAt)) {
        latestByQuiz[attempt.quizId] = attempt;
      }
    }

    final quizzes = latestByQuiz.values.map((attempt) {
      final timestamp = attempt.submittedAt ?? DateTime(2000);
      return _QuizResult(
        attempt.quizTitle.isEmpty ? 'Quiz' : attempt.quizTitle,
        attempt.submittedAt == null
            ? 'Just now'
            : _formatDate(attempt.submittedAt!),
        attempt.score,
        attempt.totalQuestions,
        timestamp,
      );
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final totalPercentage = latestByQuiz.values.fold<double>(
      0,
      (total, attempt) => total + (attempt.score / attempt.totalQuestions),
    );
    final average = latestByQuiz.isEmpty
        ? 0.0
        : (totalPercentage / latestByQuiz.length) * 100;

    setState(() {
      _quizzes = quizzes;
      _avgQuiz = '${average.toStringAsFixed(0)}%';
      _quizPage = 0;
      _loading = false;
    });
  }

  void _applyArActivity(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    final experiments = <_ArExperimentResult>[];
    var totalScore = 0.0;
    for (final document in documents) {
      final data = document.data();
      final completedAt = data['completedAt'];
      if (completedAt is! Timestamp) continue;
      final timestamp = completedAt.toDate();
      final score = _arScore(data);
      final experimentId = (data['experimentId'] as String?)?.trim();
      final storedTitle = (data['experimentTitle'] as String?)?.trim();
      experiments.add(
        _ArExperimentResult(
          storedTitle != null && storedTitle.isNotEmpty
              ? storedTitle
              : _arExperimentTitle(
                  experimentId == null || experimentId.isEmpty
                      ? document.id
                      : experimentId,
                ),
          _formatDate(timestamp),
          score,
          timestamp,
        ),
      );
      totalScore += score;
    }
    experiments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    setState(() {
      _arExperiments = experiments;
      _arPage = 0;
      _avgAr = experiments.isEmpty
          ? '0.0'
          : (totalScore / experiments.length).toStringAsFixed(1);
    });
  }

  double _arScore(Map<String, dynamic> data) {
    final legacyScore = data['score'];
    if (legacyScore is num) {
      return legacyScore.toDouble().clamp(0, 100).toDouble();
    }

    final rubric = data['rubricScores'];
    if (rubric is Map) {
      final total = rubric['total'];
      if (total is num) return total.toDouble().clamp(0, 100).toDouble();
    }
    return 0;
  }

  String _arExperimentTitle(String experimentId) {
    for (final experiment in dummyArExperiments) {
      if (experiment.id.toLowerCase() == experimentId.toLowerCase()) {
        return experiment.title;
      }
    }
    return experimentId;
  }

  Future<void> _loadMissedQuizzes(
    AppUser user,
    Set<String> attemptedQuizIds,
    int version,
    int missedLoadVersion,
  ) async {
    try {
      final assignedCourses = await context
          .read<CourseService>()
          .fetchCoursesForStudent(user);
      final missedQuizzes = <_MissedQuizResult>[];
      for (final course in assignedCourses) {
        for (final quiz in course.quizzes) {
          final dueDate = quiz.dueDate;
          if (!attemptedQuizIds.contains(quiz.id) &&
              dueDate != null &&
              dueDate.isBefore(DateTime.now())) {
            missedQuizzes.add(
              _MissedQuizResult(quiz.title, _formatDate(dueDate), dueDate),
            );
          }
        }
      }
      missedQuizzes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (mounted &&
          version == _dataVersion &&
          missedLoadVersion == _missedLoadVersion) {
        setState(() {
          _missedQuizzes = missedQuizzes;
          _missedPage = 0;
        });
      }
    } catch (error) {
      debugPrint('Error fetching missed quizzes: $error');
    }
  }

  @override
  void dispose() {
    _authService.removeListener(_handleStudentChanged);
    _dataVersion++;
    _quizAttemptsSub?.cancel();
    _arActivitySub?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
              )
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
                  ..._buildPagedQuizSection(),
                  SliverToBoxAdapter(
                    child: _buildAnimatedSection(
                      delay: 250,
                      child: _buildSectionHeader(
                        'Missed Quizzes',
                        'warning',
                        color: const Color(0xFFFF4757),
                      ),
                    ),
                  ),
                  ..._buildPagedMissedSection(),
                  SliverToBoxAdapter(
                    child: _buildAnimatedSection(
                      delay: 300,
                      child: _buildSectionHeader('AR Experiments', 'science'),
                    ),
                  ),
                  ..._buildPagedArSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final slide =
            Tween<Offset>(
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
          child: FadeTransition(opacity: _entranceController, child: child),
        );
      },
      child: child,
    );
  }

  // ── Paged section builders ───────────────────────────────────────────

  List<Widget> _buildPagedQuizSection() {
    if (_quizzes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'No quizzes completed yet.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ];
    }
    final start = _quizPage * _pageSize;
    final visible = _quizzes.skip(start).take(_pageSize).toList();
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAnimatedSection(
            delay: 200 + (index * 50),
            child: _buildQuizCard(visible[index]),
          ),
          childCount: visible.length,
        ),
      ),
      if (_quizzes.length > _pageSize)
        SliverToBoxAdapter(
          child: _buildPaginationControls(
            currentPage: _quizPage,
            totalItems: _quizzes.length,
            onPrevious: _quizPage > 0
                ? () => setState(() => _quizPage--)
                : null,
            onNext: (start + _pageSize) < _quizzes.length
                ? () => setState(() => _quizPage++)
                : null,
          ),
        ),
    ];
  }

  List<Widget> _buildPagedMissedSection() {
    if (_missedQuizzes.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'No missed quizzes.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ];
    }
    final start = _missedPage * _pageSize;
    final visible = _missedQuizzes.skip(start).take(_pageSize).toList();
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAnimatedSection(
            delay: 300 + (index * 50),
            child: _buildMissedQuizCard(visible[index]),
          ),
          childCount: visible.length,
        ),
      ),
      if (_missedQuizzes.length > _pageSize)
        SliverToBoxAdapter(
          child: _buildPaginationControls(
            currentPage: _missedPage,
            totalItems: _missedQuizzes.length,
            onPrevious: _missedPage > 0
                ? () => setState(() => _missedPage--)
                : null,
            onNext: (start + _pageSize) < _missedQuizzes.length
                ? () => setState(() => _missedPage++)
                : null,
          ),
        ),
    ];
  }

  List<Widget> _buildPagedArSection() {
    if (_arExperiments.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'No AR experiments completed yet.',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF8BA3C0)
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        ),
      ];
    }
    final start = _arPage * _pageSize;
    final visible = _arExperiments.skip(start).take(_pageSize).toList();
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAnimatedSection(
            delay: 400 + (index * 50),
            child: _buildArExperimentCard(visible[index]),
          ),
          childCount: visible.length,
        ),
      ),
      if (_arExperiments.length > _pageSize)
        SliverToBoxAdapter(
          child: _buildPaginationControls(
            currentPage: _arPage,
            totalItems: _arExperiments.length,
            onPrevious: _arPage > 0
                ? () => setState(() => _arPage--)
                : null,
            onNext: (start + _pageSize) < _arExperiments.length
                ? () => setState(() => _arPage++)
                : null,
          ),
        ),
    ];
  }

  Widget _buildPaginationControls({
    required int currentPage,
    required int totalItems,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
  }) {
    final totalPages = (totalItems / _pageSize).ceil();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(
            icon: 'chevron_left',
            onPressed: onPrevious,
            isDark: isDark,
          ),
          const SizedBox(width: 12),
          Text(
            '${currentPage + 1} / $totalPages',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            icon: 'chevron_right',
            onPressed: onNext,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required String icon,
    required VoidCallback? onPressed,
    required bool isDark,
  }) {
    final enabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark
                ? (enabled ? const Color(0xFF0D2E3F) : const Color(0xFF0A1929))
                : (enabled ? const Color(0xFFE8F9FD) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? (enabled
                      ? const Color(0x3300D4FF)
                      : const Color(0xFF1E3A5F).withOpacity(0.3))
                  : (enabled
                      ? const Color(0xFF1565C0).withOpacity(0.3)
                      : Colors.grey.shade300),
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              size: 20,
              color: isDark
                  ? (enabled
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF8BA3C0).withOpacity(0.3))
                  : (enabled
                      ? const Color(0xFF1565C0)
                      : Colors.grey.shade400),
            ),
          ),
        ),
      ),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0D2E3F)
                  : const Color(0xFFE8F9FD),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x3300D4FF)
                    : const Color(0xFF1565C0).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'insights',
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF00D4FF)
                    : const Color(0xFF1565C0),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                Text(
                  'Student Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0x2200D4FF)
                  : const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0x5500D4FF)
                    : const Color(0xFF1565C0).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'school',
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF1565C0),
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  'Student',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF00D4FF)
                        : const Color(0xFF1565C0),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
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
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF8BA3C0)
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String icon, {
    Color color = const Color(0xFF8BA3C0),
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.date,
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${result.date}',
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
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF142240)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E3A5F)
              : Colors.grey.shade300,
        ),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.date,
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

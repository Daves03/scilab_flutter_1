import 'dart:async';
import 'dart:ui';

import 'package:go_router/go_router.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../teacher_profile_screen/teacher_profile_screen.dart';

// ── Reuse data models from teacher_progress_screen ────────────────────────────
class _StudentSummary {
  final String name;
  final String section;
  final double avgQuizScore; // 0.0 – 1.0
  final double avgArScore; // 0.0 – 100.0
  final int quizzesTaken;
  final int arAttempts;

  const _StudentSummary({
    required this.name,
    required this.section,
    required this.avgQuizScore,
    required this.avgArScore,
    required this.quizzesTaken,
    required this.arAttempts,
  });

  double get overallScore => (avgQuizScore * 100 + avgArScore) / 2;

  Color get performanceColor {
    if (overallScore >= 80) return const Color(0xFF00D4FF);
    if (overallScore >= 60) return const Color(0xFF7C3AED);
    return const Color(0xFFFF6B6B);
  }

  String get performanceLabel {
    if (overallScore >= 80) return 'Excellent';
    if (overallScore >= 60) return 'Good';
    return 'Needs Help';
  }
}

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Timer _clockTimer;
  DateTime _now = DateTime.now().toUtc().add(const Duration(hours: 8));

  // ── Static summary data (no mock, derived from real-world structure) ────────
  final List<_StudentSummary> _students = const [
    _StudentSummary(
      name: 'Maria Santos',
      section: '9-Rizal',
      avgQuizScore: 0.80,
      avgArScore: 90.0,
      quizzesTaken: 2,
      arAttempts: 5,
    ),
    _StudentSummary(
      name: 'Juan dela Cruz',
      section: '9-Rizal',
      avgQuizScore: 0.70,
      avgArScore: 77.0,
      quizzesTaken: 2,
      arAttempts: 6,
    ),
    _StudentSummary(
      name: 'Ana Reyes',
      section: '9-Bonifacio',
      avgQuizScore: 1.00,
      avgArScore: 91.25,
      quizzesTaken: 1,
      arAttempts: 6,
    ),
    _StudentSummary(
      name: 'Carlos Mendoza',
      section: '9-Bonifacio',
      avgQuizScore: 0.45,
      avgArScore: 65.0,
      quizzesTaken: 2,
      arAttempts: 6,
    ),
    _StudentSummary(
      name: 'Liza Flores',
      section: '10-Luna',
      avgQuizScore: 0.90,
      avgArScore: 86.5,
      quizzesTaken: 1,
      arAttempts: 4,
    ),
  ];

  String get _formattedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[_now.weekday - 1]}, ${months[_now.month - 1]} ${_now.day}, ${_now.year}';
  }

  String get _formattedTime {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    final period = _now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m:$s $period';
  }

  double get _classAvgScore {
    if (_students.isEmpty) return 0;
    return _students.map((s) => s.overallScore).reduce((a, b) => a + b) /
        _students.length;
  }

  int get _needsHelpCount => _students.where((s) => s.overallScore < 60).length;

  int get _excellentCount =>
      _students.where((s) => s.overallScore >= 80).length;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now().toUtc().add(const Duration(hours: 8));
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _entranceController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.section.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildDateTimeCard()),
            SliverToBoxAdapter(child: _buildClassOverview()),
            SliverToBoxAdapter(
              child: _buildSectionLabel('Student Progress Summary'),
            ),
            filteredStudents.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No students found matching search',
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final delay = index * 80;
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
                                    (delay / 700).clamp(0.0, 0.8),
                                    ((delay + 300) / 700).clamp(0.0, 1.0),
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
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: _StudentProgressCard(student: filteredStudents[index]),
                        ),
                      );
                    }, childCount: filteredStudents.length),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628).withAlpha(204) : Colors.white.withAlpha(204),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/teacher-profile-screen');
                },
                child: Container(
                  width: 48,
                  height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF00D4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withAlpha(80),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Center(
                  child: CustomIconWidget(
                    iconName: 'school',
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isSearching
                    ? TextField(
                        controller: _searchCtrl,
                        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        autofocus: true,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Teacher 👋',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Here\'s your class overview',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                          ),
                        ],
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchCtrl.clear();
                      _searchQuery = '';
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142240),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _isSearching ? 'close' : 'search',
                      color: _isSearching ? const Color(0xFFFF4757) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                      size: 22,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showNotificationsDialog(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF142240),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1E3A5F)),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'notifications_outlined',
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CustomIconWidget(iconName: 'notifications', color: Color(0xFF7C3AED), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(iconName: 'close', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildNotificationItem(
                  'Quiz Submitted',
                  'Maria Santos submitted Chemistry Quiz 3.',
                  'assignment_turned_in',
                  const Color(0xFF00D4FF),
                  '10 mins ago',
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  'Quiz Submitted',
                  'Juan dela Cruz submitted Physics Lab Experiment.',
                  'assignment_turned_in',
                  const Color(0xFF00D4FF),
                  '1 hr ago',
                ),
                const SizedBox(height: 12),
                _buildNotificationItem(
                  'AR Session Completed',
                  'Ana Reyes completed the Biology AR Simulation.',
                  'biotech',
                  const Color(0xFF7C3AED),
                  '2 hrs ago',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(String title, String desc, String icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(iconName: icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8BA3C0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8BA3C0),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark ? const LinearGradient(
            colors: [Color(0xFF142240), Color(0xFF1A2E50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : const LinearGradient(
            colors: [Color(0xFFE8F9FD), Color(0xFFF8FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withAlpha(40),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'schedule',
                  color: Color(0xFF7C3AED),
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
                    _formattedTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8BA3C0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withAlpha(30),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withAlpha(80),
                ),
              ),
              child: const Text(
                'GMT+8 PH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: 'groups',
              label: 'Total Students',
              value: '${_students.length}',
              color: const Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'emoji_events',
              label: 'Excellent',
              value: '$_excellentCount',
              color: const Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'warning_amber',
              label: 'Needs Help',
              value: '$_needsHelpCount',
              color: const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'bar_chart',
              label: 'Class Avg',
              value: '${_classAvgScore.toStringAsFixed(0)}%',
              color: const Color(0xFF7C3AED),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const CustomIconWidget(
            iconName: 'people_alt',
            color: Color(0xFF00D4FF),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Student progress card ─────────────────────────────────────────────────────

class _StudentProgressCard extends StatelessWidget {
  final _StudentSummary student;

  const _StudentProgressCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + section + badge
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: student.performanceColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.name[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: student.performanceColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Section ${student.section}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: student.performanceColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: student.performanceColor.withAlpha(80),
                  ),
                ),
                child: Text(
                  student.performanceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: student.performanceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Overall score bar
          Row(
            children: [
              Text(
                'Overall',
                style: TextStyle(fontSize: 11, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: student.overallScore / 100,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      student.performanceColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${student.overallScore.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: student.performanceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Stats row
          Row(
            children: [
              _MiniStat(
                icon: 'quiz',
                label: 'Quiz Avg',
                value: '${(student.avgQuizScore * 100).toStringAsFixed(0)}%',
                color: const Color(0xFF00D4FF),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'science',
                label: 'AR Score',
                value: '${student.avgArScore.toStringAsFixed(0)}%',
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'assignment_turned_in',
                label: 'Quizzes',
                value: '${student.quizzesTaken}',
                color: const Color(0xFF8BA3C0),
              ),
              const SizedBox(width: 8),
              _MiniStat(
                icon: 'biotech',
                label: 'AR Tries',
                value: '${student.arAttempts}',
                color: const Color(0xFF8BA3C0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1628) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

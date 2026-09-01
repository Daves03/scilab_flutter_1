import 'dart:async';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';

import 'package:go_router/go_router.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/activity_model.dart';
import '../teacher_profile_screen/teacher_profile_screen.dart';
import 'widgets/student_approval_dialog.dart';
import '../student_home_screen/widgets/user_header_widget.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

// ── Reuse data models from teacher_progress_screen ────────────────────────────
class _StudentSummary {
  final String name;
  final String section;
  final String? studentNumber;
  final double avgQuizScore; // 0.0 – 1.0
  final double avgArScore; // 0.0 – 100.0
  final int quizzesTaken;
  final int arAttempts;

  const _StudentSummary({
    required this.name,
    required this.section,
    this.studentNumber,
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

enum DashboardTab { allStudents, needsHelp, classAvg }

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

  List<_StudentSummary> _students = [];
  bool _loading = true;
  DashboardTab _currentTab = DashboardTab.allStudents;
  
  final StreamController<List<Map<String, dynamic>>> _notifController = StreamController.broadcast();
  StreamSubscription? _usersSub;
  StreamSubscription? _quizSub;
  StreamSubscription? _arSub;

  List<QueryDocumentSnapshot> _pendingUsers = [];
  List<QueryDocumentSnapshot> _quizAttempts = [];
  List<QueryDocumentSnapshot> _arAttempts = [];
  
  final Map<String, DateTime> _pendingUserTimestamps = {};

  Future<void> _loadData() async {
    try {
      final db = FirebaseFirestore.instance;

      final studentsSnap = await db
          .collection('users')
          .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
          .where('status', isEqualTo: VerificationStatus.approved.id)
          .get();
          
      final users = studentsSnap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();

      final attemptsSnap = await db.collection('quiz_attempts').get();
      final allAttempts = attemptsSnap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList();

      List<_StudentSummary> dynamicStudents = [];
      for (var u in users) {
         final uAttempts = allAttempts.where((a) => a.studentId == u.id).toList();
         
         double avgQuizScore = 0;
         if (uAttempts.isNotEmpty) {
           double totalScore = 0;
           for (var a in uAttempts) {
             totalScore += (a.totalQuestions > 0 ? a.score / a.totalQuestions : 0);
           }
           avgQuizScore = totalScore / uAttempts.length;
         }

         int arAttempts = 0;
         double avgArScore = 0.0;
         try {
           final uArSnap = await db.collection('users').doc(u.id).collection('experiment_activity').get();
           arAttempts = uArSnap.docs.length;
           int completed = 0;
           for (var d in uArSnap.docs) {
             final act = ExperimentActivity.fromMap(d.id, d.data());
             if (act.completed) completed++;
           }
           if (arAttempts > 0) {
              avgArScore = (completed / arAttempts) * 100.0;
           }
         } catch (e) {
           print('Error fetching AR records for ${u.id}: $e');
         }

         final section = u.sections.isNotEmpty ? u.sections.first : 'No Section';

         dynamicStudents.add(_StudentSummary(
           name: u.name,
           section: section,
           studentNumber: u.studentNumber,
           avgQuizScore: avgQuizScore,
           avgArScore: avgArScore,
           quizzesTaken: uAttempts.length,
           arAttempts: arAttempts,
         ));
      }

      if (mounted) {
        setState(() {
          _students = dynamicStudents;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading dynamic progress: $e');
      if (mounted) {
        setState(() { _loading = false; });
      }
    }
  }

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
  String _selectedChartSection = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now().toUtc().add(const Duration(hours: 8));
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotificationStreams();
    });
  }

  void _initNotificationStreams() {
    final db = FirebaseFirestore.instance;
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    
    void updateNotifs() async {
      List<Map<String, dynamic>> notifications = [];
      final teacherSections = user.sections;
      
      // 1. Pending Users
      for (var doc in _pendingUsers) {
        final u = AppUser.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        if (u.sections.any((s) => teacherSections.contains(s))) {
          if (!_pendingUserTimestamps.containsKey(u.id)) {
            _pendingUserTimestamps[u.id] = DateTime.now();
          }
          notifications.add({
            'title': 'New Student Approval',
            'desc': '${u.name} requested to join ${u.sections.first}.',
            'icon': 'person_add',
            'color': const Color(0xFF7C3AED),
            'timestamp': _pendingUserTimestamps[u.id]!,
            'action': 'approval',
          });
        }
      }

      // 2. Quiz Attempts
      for (var doc in _quizAttempts) {
        final data = doc.data() as Map<String, dynamic>;
        final studentId = data['studentId'] as String? ?? '';
        final title = data['quizTitle'] as String? ?? '';
        final ts = data['submittedAt'] as Timestamp?;
        // We only have the top 10 recent quizzes, so fetching names individually is okay
        String name = 'A student';
        if (studentId.isNotEmpty) {
           final sDoc = await db.collection('users').doc(studentId).get();
           if (sDoc.exists) name = sDoc.data()?['name'] ?? name;
        }
        notifications.add({
          'title': 'Quiz Submitted',
          'desc': '$name submitted $title.',
          'icon': 'assignment_turned_in',
          'color': const Color(0xFF00D4FF),
          'timeStr': _formatNotificationTime(ts?.toDate()),
          'timestamp': ts?.toDate() ?? DateTime.now(),
        });
      }

      // 3. AR Results
      for (var doc in _arAttempts) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['experimentId'] as String? ?? 'Experiment';
        final ts = data['completedAt'] as Timestamp?;
        // Parent doc id is the studentId
        String name = 'A student';
        final parentRef = doc.reference.parent.parent;
        if (parentRef != null) {
           final sDoc = await parentRef.get();
           if (sDoc.exists) name = sDoc.data()?['name'] ?? name;
        }
        notifications.add({
          'title': 'AR Activity Completed',
          'desc': '$name completed $title.',
          'icon': 'view_in_ar',
          'color': const Color(0xFFFFB300),
          'timeStr': _formatNotificationTime(ts?.toDate()),
          'timestamp': ts?.toDate() ?? DateTime.now(),
        });
      }

      notifications.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
      _notifController.add(notifications);
    }

    _usersSub = db.collection('users')
      .where('role', whereIn: [UserRole.grade9.id, UserRole.grade10.id])
      .where('status', isEqualTo: VerificationStatus.pending.id)
      .snapshots().listen((snap) {
        _pendingUsers = snap.docs;
        updateNotifs();
      });

    _quizSub = db.collection('quiz_attempts')
      .orderBy('submittedAt', descending: true).limit(10)
      .snapshots().listen((snap) {
        _quizAttempts = snap.docs;
        updateNotifs();
      });
      
    // Collection group query might fail if index is missing, so we wrap in try-catch or limit
    try {
      _arSub = db.collectionGroup('experiment_activity')
        .where('completed', isEqualTo: true)
        // Can't orderBy completedAt easily without composite index, so just listen
        .snapshots().listen((snap) {
          final sorted = snap.docs.toList()..sort((a, b) {
            final ta = (a.data() as Map<String, dynamic>)['completedAt'] as Timestamp?;
            final tb = (b.data() as Map<String, dynamic>)['completedAt'] as Timestamp?;
            if (ta == null || tb == null) return 0;
            return tb.compareTo(ta);
          });
          _arAttempts = sorted.take(10).toList();
          updateNotifs();
        });
    } catch (e) {
      print('AR notification stream failed: $e');
    }
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _quizSub?.cancel();
    _arSub?.cancel();
    _notifController.close();
    _searchCtrl.dispose();
    _entranceController.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<_StudentSummary> activeStudents = _students;
    if (_currentTab == DashboardTab.needsHelp) {
      activeStudents = _students.where((s) => s.overallScore < 60).toList();
    }

    final filteredStudents = activeStudents.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.section.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))) : CustomScrollView(
              slivers: [
            SliverToBoxAdapter(
              child: _buildHeader()
            ),
            SliverToBoxAdapter(child: _buildDateTimeCard()),
            SliverToBoxAdapter(child: _buildClassOverview()),
            if (_currentTab == DashboardTab.classAvg)
              SliverToBoxAdapter(
                child: _buildClassAvgChart(),
              )
            else ...[
              SliverToBoxAdapter(
                child: _buildSectionLabel('Student Progress Summary'),
              ),
              filteredStudents.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'No students found',
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
                            child: _StudentProgressCard(
                              student: filteredStudents[index],
                              showBadge: _currentTab == DashboardTab.needsHelp,
                            ),
                          ),
                        );
                      }, childCount: filteredStudents.length),
                    ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
            Positioned(
              bottom: 124,
              right: 20,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  final result = await showDialog(
                    context: context,
                    builder: (_) => const StudentApprovalDialog(),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                backgroundColor: const Color(0xFF00D4FF),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const CustomIconWidget(
                  iconName: 'person_add_outlined',
                  color: Color(0xFF0A1628), // Dark color for contrast
                  size: 28,
                ),
              ),
            ),
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
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _notifController.stream,
                builder: (context, snapshot) {
                  final user = context.watch<AuthService>().currentUser;
                  final lastRead = user?.lastNotificationReadAt ?? DateTime(2000);
                  final notifs = snapshot.data ?? [];
                  final hasUnread = notifs.any((n) => (n['timestamp'] as DateTime).isAfter(lastRead));
                  
                  return GestureDetector(
                    onTap: () {
                      context.read<AuthService>().markNotificationsAsRead();
                      _showNotificationsDialog(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF142240),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1E3A5F)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: CustomIconWidget(
                              iconName: 'notifications_outlined',
                              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600,
                              size: 22,
                            ),
                          ),
                          if (hasUnread)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00D4FF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
  }

  // _fetchDynamicNotifications removed, replaced by Stream


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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notifController.stream,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final notifs = snapshot.data ?? [];
                return Column(
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
                    if (notifs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No recent activity.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...notifs.map((n) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNotificationItem(
                            n['title'] as String,
                            n['desc'] as String,
                            n['icon'] as String,
                            n['color'] as Color,
                            n['timeStr'] as String,
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
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
              color: _currentTab == DashboardTab.allStudents ? const Color(0xFF00D4FF) : const Color(0xFF00D4FF).withAlpha(128),
              onTap: () => setState(() => _currentTab = DashboardTab.allStudents),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'warning_amber',
              label: 'Needs Help',
              value: '$_needsHelpCount',
              color: _currentTab == DashboardTab.needsHelp ? const Color(0xFFFF6B6B) : const Color(0xFFFF6B6B).withAlpha(128),
              onTap: () => setState(() => _currentTab = DashboardTab.needsHelp),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: 'bar_chart',
              label: 'Class Avg',
              value: '${_classAvgScore.toStringAsFixed(0)}%',
              color: _currentTab == DashboardTab.classAvg ? const Color(0xFF7C3AED) : const Color(0xFF7C3AED).withAlpha(128),
              onTap: () => setState(() => _currentTab = DashboardTab.classAvg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAvgChart() {
    if (_students.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'No student data available',
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }

    final sections = ['All'];
    for (var s in _students) {
      if (!sections.contains(s.section)) {
        sections.add(s.section);
      }
    }

    final List<String> xAxisLabels = [];
    final List<double> yValues = [];
    final List<Color> barColors = [];
    final List<String> tooltips = [];

    if (_selectedChartSection == 'All') {
      final Map<String, List<_StudentSummary>> grouped = {};
      for (var s in _students) {
        grouped.putIfAbsent(s.section, () => []).add(s);
      }
      
      final sortedSections = grouped.keys.toList()..sort();
      for (var sec in sortedSections) {
        final sectionStudents = grouped[sec]!;
        final avg = sectionStudents.map((s) => s.overallScore).reduce((a, b) => a + b) / sectionStudents.length;
        
        Color c = const Color(0xFF00D4FF);
        if (avg >= 80) c = const Color(0xFF00D4FF);
        else if (avg >= 60) c = const Color(0xFF7C3AED);
        else c = const Color(0xFFFF6B6B);
        
        String shortSec = sec.length > 10 ? sec.substring(0, 10) + '...' : sec;
        
        xAxisLabels.add(shortSec);
        yValues.add(avg);
        barColors.add(c);
        tooltips.add('Section $sec\nAvg: ${avg.toStringAsFixed(1)}%');
      }
    } else {
      final filteredStudents = _students.where((s) => s.section == _selectedChartSection).toList();
      filteredStudents.sort((a, b) => a.name.compareTo(b.name));
      
      for (var s in filteredStudents) {
        String shortName = s.name.split(' ').first;
        if (shortName.length > 6) shortName = shortName.substring(0, 6) + '.';
        
        xAxisLabels.add(shortName);
        yValues.add(s.overallScore);
        barColors.add(s.performanceColor);
        tooltips.add('${s.name}\n${s.section}\n${s.overallScore.toStringAsFixed(1)}%');
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Overall Scores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sections.map((sec) {
                final isSelected = _selectedChartSection == sec;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedChartSection = sec;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF00D4FF).withAlpha(40) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00D4FF) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        sec == 'All' ? 'All Sections' : 'Section $sec',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected 
                              ? const Color(0xFF00D4FF) 
                              : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: yValues.isEmpty 
              ? Center(
                  child: Text(
                    'No data in this section',
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600, fontSize: 14),
                  ),
                )
              : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        tooltips[group.x],
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < xAxisLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(xAxisLabels[value.toInt()], style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 20 != 0) return const SizedBox.shrink();
                        return Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade600));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(yValues.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: yValues[i],
                        color: barColors[i],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF142240) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3A5F) : Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomIconWidget(iconName: 'info_outline', color: Color(0xFF00D4FF), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This chart displays the individual overall score of every student you handle across all sections. The overall score represents an equal average between your students\' Quiz results and their performance in the AR Laboratory.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    ));
  }
}

// ── Student progress card ─────────────────────────────────────────────────────

class _StudentProgressCard extends StatelessWidget {
  final _StudentSummary student;
  final bool showBadge;

  const _StudentProgressCard({required this.student, this.showBadge = true});

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (student.studentNumber != null && student.studentNumber!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: showBadge ? 6.0 : 0),
                      child: Text(
                        '#${student.studentNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF00D4FF) : const Color(0xFF00A0D4),
                        ),
                      ),
                    ),
                  if (showBadge)
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

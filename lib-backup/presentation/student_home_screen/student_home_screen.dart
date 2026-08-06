import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/course_card_widget.dart';
import './widgets/progress_chart_widget.dart';
import './widgets/recent_quiz_widget.dart';
import './widgets/user_header_widget.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  static const List<Map<String, dynamic>> _courseMaps = [
    {
      'id': 'c1',
      'title': 'Organic Chemistry Fundamentals',
      'category': 'Organic Chemistry',
      'grade': 'Grade 10',
      'chapters': 8,
      'progress': 0.75,
      'rating': 4.8,
      'iconName': 'biotech',
      'tintColorValue': 0xFF0D2E3F,
      'studentAvatarUrls': [
        'https://images.pexels.com/photos/4145153/pexels-photo-4145153.jpeg',
        'https://pixabay.com/get/g5f9a2f7c.jpg',
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=60&h=60&fit=crop',
      ],
      'enrolledCount': 142,
      'semanticLabel':
          'Chemistry student working at laboratory bench with test tubes',
    },
    {
      'id': 'c2',
      'title': 'Inorganic Chemistry Basics',
      'category': 'Inorganic Chemistry',
      'grade': 'Grade 9',
      'chapters': 6,
      'progress': 0.40,
      'rating': 4.5,
      'iconName': 'hub',
      'tintColorValue': 0xFF1E1535,
      'studentAvatarUrls': [
        'https://images.pexels.com/photos/3825527/pexels-photo-3825527.jpeg',
        'https://pixabay.com/get/ga7b3c9d2.jpg',
      ],
      'enrolledCount': 98,
      'semanticLabel': 'Colorful molecular model structure on dark background',
    },
    {
      'id': 'c3',
      'title': 'Physical Chemistry: Thermodynamics',
      'category': 'Physical Chemistry',
      'grade': 'Grade 11',
      'chapters': 10,
      'progress': 0.20,
      'rating': 4.3,
      'iconName': 'thermostat',
      'tintColorValue': 0xFF0D2E1F,
      'studentAvatarUrls': [
        'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
      ],
      'enrolledCount': 67,
      'semanticLabel':
          'Chemistry laboratory with flasks and Bunsen burner flames',
    },
    {
      'id': 'c4',
      'title': 'Biochemistry Introduction',
      'category': 'Biochemistry',
      'grade': 'Grade 12',
      'chapters': 7,
      'progress': 0.0,
      'rating': 4.6,
      'iconName': 'coronavirus',
      'tintColorValue': 0xFF2E2010,
      'studentAvatarUrls': [
        'https://images.pexels.com/photos/1366942/pexels-photo-1366942.jpeg',
        'https://pixabay.com/get/g8e4f1a5b.jpg',
      ],
      'enrolledCount': 53,
      'semanticLabel':
          'Laboratory equipment including pipettes and petri dishes',
    },
  ];

  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _courses = _courseMaps
        .map(
          (m) => CourseModel(
            id: m['id'] as String,
            title: m['title'] as String,
            category: m['category'] as String,
            grade: m['grade'] as String,
            chapters: m['chapters'] as int,
            progress: (m['progress'] as num).toDouble(),
            rating: (m['rating'] as num).toDouble(),
            iconName: m['iconName'] as String,
            tintColor: Color(m['tintColorValue'] as int),
            studentAvatarUrls: List<String>.from(
              m['studentAvatarUrls'] as List,
            ),
            enrolledCount: m['enrolledCount'] as int,
            semanticLabel: m['semanticLabel'] as String,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        bottom: false,
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: UserHeaderWidget(onNotificationTap: () {})),
        SliverToBoxAdapter(child: _buildSectionHeader()),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final delay = index * 80;
            return AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final offsetAnimation =
                    Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(
                          (delay / 600).clamp(0.0, 0.8),
                          ((delay + 300) / 600).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    );
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: _entranceController,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: CourseCardWidget(
                  course: _courses[index],
                  onTap: () =>
                      context.go(AppRoutes.studentArAndVideoLessonScreen),
                ),
              ),
            );
          }, childCount: _courses.length),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _buildProgressSectionHeader(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProgressChartWidget(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: _buildRecentQuizHeader(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: const RecentQuizWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: UserHeaderWidget(onNotificationTap: () {}),
              ),
              SliverToBoxAdapter(child: _buildSectionHeader()),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: CourseCardWidget(
                      course: _courses[index],
                      onTap: () =>
                          context.go(AppRoutes.studentArAndVideoLessonScreen),
                    ),
                  ),
                  childCount: _courses.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 80),
                ProgressChartWidget(),
                const SizedBox(height: 20),
                const RecentQuizWidget(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'Your Progress\nToday',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF142240),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'search',
                  color: Color(0xFF8BA3C0),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSectionHeader() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'insights',
          color: const Color(0xFF00D4FF),
          size: 20,
        ),
        const SizedBox(width: 8),
        const Text(
          'Monthly Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentQuizHeader() {
    return const Text(
      'Recent Quizzes',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

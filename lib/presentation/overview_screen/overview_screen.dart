import 'dart:math' as math;

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late PageController _featurePageController;
  int _currentFeaturePage = 0;

  late PageController _arPreviewController;
  int _currentArPreviewPage = 0;

  final List<String> _arPreviewImages = const [
    'assets/images/ar_preview_1.png',
    'assets/images/ar_preview_2.png',
    'assets/images/ar_preview_3.png',
    'assets/images/ar_preview_5.png',
  ];

  final List<_FeatureItem> _features = const [
    _FeatureItem(
      icon: 'view_in_ar',
      title: 'AR Chemistry Lab',
      subtitle: 'Perform chemistry experiments in AR',
      description:
          'Conduct virtual experiments like Flame Tests and Elephant Toothpaste. Follow guided steps and watch reactions unfold in 3D.',
      color: AppTheme.accentCyan,
      tint: AppTheme.tintCyan,
      imageUrl:
          'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
      imageLabel: 'Chemistry laboratory with glowing blue molecular structures',
    ),
    _FeatureItem(
      icon: 'play_circle_filled',
      title: 'Video Lessons',
      subtitle: 'Recommended chemistry video lessons',
      description:
          'Stream YouTube video recommendations based on the specific chemistry topics and AR experiments you are exploring.',
      color: AppTheme.accentPurple,
      tint: AppTheme.tintPurple,
      imageUrl:
          'https://images.pexels.com/photos/4145153/pexels-photo-4145153.jpeg',
      imageLabel: 'Student watching chemistry video lesson on tablet device',
    ),
    _FeatureItem(
      icon: 'quiz',
      title: 'Smart Quizzes',
      subtitle: 'Build custom quizzes or generate with AI',
      description:
          'Teachers can create quizzes manually or use AI to instantly generate questions by analyzing attached course modules.',
      color: AppTheme.accentGreen,
      tint: AppTheme.tintGreen,
      imageUrl:
          'https://images.pexels.com/photos/1366942/pexels-photo-1366942.jpeg',
      imageLabel: 'Student taking chemistry quiz on digital device',
    ),
    _FeatureItem(
      icon: 'menu_book',
      title: 'Course Library',
      subtitle: 'Access structured courses tailored for your class',
      description:
          'Follow teacher-guided learning paths with modules, interactive quizzes, and seamless progress tracking.',
      color: AppTheme.warningAmber,
      tint: AppTheme.tintAmber,
      imageUrl:
          'https://images.pexels.com/photos/3825527/pexels-photo-3825527.jpeg',
      imageLabel: 'Open chemistry textbook with colorful molecular diagrams',
    ),
    _FeatureItem(
      icon: 'insights',
      title: 'Progress Tracking',
      subtitle: 'Monitor your learning journey',
      description:
          'Keep track of your quiz scores, completed modules, and overall course progression in real-time.',
      color: AppTheme.accentCyan,
      tint: AppTheme.tintCyan,
      imageUrl:
          'https://images.pexels.com/photos/5905717/pexels-photo-5905717.jpeg',
      imageLabel: 'Student tracking progress on digital device',
    ),
    _FeatureItem(
      icon: 'verified_user',
      title: 'Secure Classrooms',
      subtitle: 'Learn safely with teacher approval',
      description:
          'Join secure digital classrooms where your teachers approve access, curate content, and monitor your progress.',
      color: AppTheme.accentPurple,
      tint: AppTheme.tintPurple,
      imageUrl:
          'https://images.pexels.com/photos/4143791/pexels-photo-4143791.jpeg',
      imageLabel: 'Teacher guiding a student in a classroom',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _featurePageController = PageController(viewportFraction: 0.88);
    _featurePageController.addListener(() {
      final page = _featurePageController.page?.round() ?? 0;
      if (page != _currentFeaturePage) {
        setState(() => _currentFeaturePage = page);
      }
    });

    _arPreviewController = PageController();
    _arPreviewController.addListener(() {
      final page = _arPreviewController.page?.round() ?? 0;
      if (page != _currentArPreviewPage) {
        setState(() => _currentArPreviewPage = page);
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _featurePageController.dispose();
    _arPreviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 32),
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildFeaturesSection(),
                        const SizedBox(height: 32),
                        _buildCTASection(),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        return CustomPaint(
          painter: _BackgroundPainter(_floatController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withAlpha(38),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: AppTheme.accentCyan.withAlpha(77),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/scilab_logo-1784970842098.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                semanticLabel: 'ScilabAR logo',
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Scilab AR',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(AppRoutes.signUpLoginScreen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentCyan.withAlpha(128),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentCyan,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        final fade = CurvedAnimation(
          parent: _heroController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        );
        final slide =
            Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _heroController,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
              ),
            );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentCyan.withAlpha(31),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppTheme.accentCyan.withAlpha(64),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) => Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGreen.withOpacity(
                              0.4 + 0.4 * _pulseController.value,
                            ),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chemistry Education Reimagined',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentCyan,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Learn Chemistry\n',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  TextSpan(
                    text: 'in Augmented\nReality',
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentCyan,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Explore molecules, run virtual experiments, and master chemistry concepts through immersive AR — built for students, Grades 9–10.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _arPreviewController,
                itemCount: _arPreviewImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(_arPreviewImages[index]),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: AppTheme.accentCyan.withAlpha(51),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(_arPreviewImages.length, (i) {
                  final isActive = i == _currentArPreviewPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accentCyan
                          : AppTheme.textCaption.withAlpha(102),
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.signUpLoginScreen),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accentCyan, Color(0xFF0099CC)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withAlpha(89),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    _featurePageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: AppTheme.accentCyan.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppTheme.accentCyan,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Courses', 'icon': 'menu_book'},
      {'label': 'AR Experiments', 'icon': 'view_in_ar'},
      {'label': 'Students', 'icon': 'people'},
      {'label': 'Profile', 'icon': 'person'},
    ];

    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        final fade = CurvedAnimation(
          parent: _heroController,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
        );
        return FadeTransition(opacity: fade, child: child);
      },
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          itemCount: stats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final s = stats[i];
            return Container(
              width: 90,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppTheme.accentCyan.withAlpha(31),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: s['icon']!,
                    color: AppTheme.accentCyan,
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s['label']!,
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'What you\'ll explore',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _featurePageController,
            itemCount: _features.length,
            itemBuilder: (context, index) {
              return AnimatedScale(
                scale: _currentFeaturePage == index ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _FeatureCard(feature: _features[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: List.generate(_features.length, (i) {
              final isActive = i == _currentFeaturePage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? _features[_currentFeaturePage].color
                      : AppTheme.textCaption.withAlpha(102),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }


  Widget _buildCTASection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentCyan.withAlpha(38),
              AppTheme.accentPurple.withAlpha(31),
            ],
          ),
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: AppTheme.accentCyan.withAlpha(51),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -4 * _floatController.value),
                child: child,
              ),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withAlpha(38),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentCyan.withAlpha(77),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppTheme.accentCyan,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to start learning?',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Join hundreds of students mastering chemistry through immersive AR experiences.',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.signUpLoginScreen),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentCyan, Color(0xFF0099CC)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withAlpha(102),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Create Account',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.go(AppRoutes.signUpLoginScreen),
              child: Text(
                'Already have an account? Sign in →',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feature data model ────────────────────────────────────────────────────────

class _FeatureItem {
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color tint;
  final String imageUrl;
  final String imageLabel;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.tint,
    required this.imageUrl,
    required this.imageLabel,
  });
}

// ── Feature card widget ───────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreviewDialog(context),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: feature.color.withAlpha(51), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: feature.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: feature.tint),
                    errorWidget: (_, __, ___) => Container(
                      color: feature.tint,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: feature.color.withAlpha(102),
                        size: 32,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppTheme.surfaceCard.withAlpha(230),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: feature.color.withAlpha(51),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: feature.color.withAlpha(89),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _iconData(feature.icon),
                        color: feature.color,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: feature.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        feature.description,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconData(feature.icon), size: 48, color: feature.color),
              const SizedBox(height: 16),
              Text(
                feature.title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Content Preview',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: feature.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in or create an account to explore ${feature.title} and access our full suite of interactive learning tools.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.signUpLoginScreen);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: feature.color,
                    foregroundColor: AppTheme.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.manrope(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'view_in_ar':
        return Icons.view_in_ar_rounded;
      case 'play_circle_filled':
        return Icons.play_circle_filled_rounded;
      case 'quiz':
        return Icons.quiz_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'insights':
        return Icons.insights_rounded;
      case 'verified_user':
        return Icons.verified_user_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}


// ── Animated background painter ───────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double progress;

  _BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-right glow
    paint.color = const Color(0xFF00D4FF).withAlpha(10);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08 + 20 * progress),
      180,
      paint,
    );

    // Bottom-left glow
    paint.color = const Color(0xFF7C5CBF).withAlpha(13);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.65 - 15 * progress),
      160,
      paint,
    );

    // Mid accent
    paint.color = const Color(0xFF00FF88).withAlpha(8);
    canvas.drawCircle(
      Offset(
        size.width * 0.5 + 20 * math.sin(progress * math.pi),
        size.height * 0.35,
      ),
      120,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.progress != progress;
}

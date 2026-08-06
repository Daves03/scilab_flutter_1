import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../routes/app_routes.dart';
class AuthHeroWidget extends StatefulWidget {
  final bool compact;
  const AuthHeroWidget({this.compact = false, super.key});

  @override
  State<AuthHeroWidget> createState() => _AuthHeroWidgetState();
}

class _AuthHeroWidgetState extends State<AuthHeroWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.compact ? 200.0 : 280.0;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color(0xFF0D2E3F),
                        const Color(0xFF1E1535),
                        const Color(0xFF0A1628),
                      ]
                    : [
                        const Color(0xFFE8F9FD),
                        const Color(0xFFF3E8FD),
                        const Color(0xFFF5F7FA),
                      ],
              ),
            ),
          ),
          // Animated particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: Size.infinite,
              );
            },
          ),
          // Chemistry illustration overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D2E3F),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withAlpha(128),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withAlpha(77),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/scilab_logo-1784970842098.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        semanticLabel: 'ScilabAR official logo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ScilabAR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chemistry Education Reimagined with AR',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF8BA3C0) : Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final offset = math.sin((progress * math.pi * 2) + i) * 10;
      final y = baseY + offset;
      final radius = 1.5 + random.nextDouble() * 2;
      final opacity = 0.2 + random.nextDouble() * 0.4;
      paint.color =
          (i % 3 == 0
                  ? const Color(0xFF00D4FF)
                  : i % 3 == 1
                  ? const Color(0xFF00FF88)
                  : const Color(0xFF7C5CBF))
              .withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

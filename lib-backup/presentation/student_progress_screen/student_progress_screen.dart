import 'dart:ui';
import '../../core/app_export.dart';

class StudentProgressScreen extends StatelessWidget {
  const StudentProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildGlassAppBar()),
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights_outlined,
                    color: Color(0xFF8BA3C0),
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coming soon',
                    style: TextStyle(fontSize: 14, color: Color(0xFF8BA3C0)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
          color: const Color(0xFF0A1628).withAlpha(204),
          child: const Row(
            children: [
              Spacer(),
              Text(
                'My Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

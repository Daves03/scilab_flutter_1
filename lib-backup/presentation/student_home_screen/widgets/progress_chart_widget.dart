import 'package:flutter/material.dart';

class ProgressChartWidget extends StatefulWidget {
  const ProgressChartWidget({super.key});

  @override
  State<ProgressChartWidget> createState() => _ProgressChartWidgetState();
}

class _ProgressChartWidgetState extends State<ProgressChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnimation;

  static const List<Map<String, dynamic>> _chartData = [
    {'month': 'Mar', 'lessons': 18, 'pct': 60},
    {'month': 'Apr', 'lessons': 22, 'pct': 73},
    {'month': 'May', 'lessons': 23, 'pct': 70},
    {'month': 'Jun', 'lessons': 44, 'pct': 100},
    {'month': 'Jul', 'lessons': 14, 'pct': 50},
  ];

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF142240),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x1400D4FF),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF00D4FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_chartData.length, (i) {
                    final d = _chartData[i];
                    final pct = (d['pct'] as int) / 100.0;
                    final animatedPct = pct * _barAnimation.value;
                    final isHighest = d['pct'] == 100;
                    return _buildBar(
                      month: d['month'] as String,
                      lessons: d['lessons'] as int,
                      pct: d['pct'] as int,
                      animatedFraction: animatedPct,
                      isHighest: isHighest,
                      barColor: isHighest
                          ? const Color(0xFF7C5CBF)
                          : i == _chartData.length - 1
                          ? const Color(0xFF4FC3A1)
                          : const Color(0xFFE8C97A),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String month,
    required int lessons,
    required int pct,
    required double animatedFraction,
    required bool isHighest,
    required Color barColor,
  }) {
    const maxBarHeight = 90.0;
    final barHeight = (maxBarHeight * animatedFraction).clamp(
      8.0,
      maxBarHeight,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (pct > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1628),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              '$pct',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 44,
              height: maxBarHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withAlpha(77),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            Container(
              width: 44,
              height: barHeight,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8BA3C0),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$lessons lessons',
          style: const TextStyle(fontSize: 10, color: Color(0xFF5A7A9A)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';

class InsightsView extends StatelessWidget {
  const InsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.backgroundBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAISynthesisCard(),
                  const SizedBox(height: 16),
                  _buildCycleLengthsCard(),
                  const SizedBox(height: 16),
                  _buildSymptomDistributionCard(),
                  const SizedBox(height: 16),
                  _buildCorrelationCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pattern Insights",
          style: GoogleFonts.quicksand(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        Text(
          "Identifying consistency over time",
          style: GoogleFonts.quicksand(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildAISynthesisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HerLunaTheme.primaryPlum,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.brainCircuit,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "AI SYNTHESIS",
                style: GoogleFonts.quicksand(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Analyzing your patterns...",
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleLengthsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.activity,
                    size: 20,
                    color: HerLunaTheme.primaryPlum,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Cycle Lengths",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HerLunaTheme.primaryPlum.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "VARIABILITY: 3 DAYS",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: HerLunaTheme.primaryPlum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar("June", 0.7, true),
              _bar("July", 0.85, false),
              _bar("Aug", 0.75, true),
              _bar("Sept", 0.8, false),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Why am I seeing this? Minor length changes are often linked to stress levels or seasonal activity shifts.",
            style: GoogleFonts.quicksand(
              fontSize: 13,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double heightFactor, bool isDark) {
    return Column(
      children: [
        Container(
          height: 100 * heightFactor,
          width: 45,
          decoration: BoxDecoration(
            color: isDark
                ? HerLunaTheme.primaryPlum
                : HerLunaTheme.primaryPlum.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black38),
        ),
      ],
    );
  }

  Widget _buildSymptomDistributionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centers the graph horizontally
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(
                  LucideIcons.barChart3,
                  size: 20,
                  color: HerLunaTheme.primaryPlum,
                ),
                const SizedBox(width: 10),
                Text(
                  "Symptom Distribution",
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Large Animated Donut Chart
          const AnimatedDonutChart(
            percentages: [0.4, 0.3, 0.2, 0.1],
            colors: [
              HerLunaTheme.primaryPlum,
              HerLunaTheme.accentPlum,
              Color(0xFFE5DEE5),
              Color(0xFFD9EAE4),
            ],
          ),

          const SizedBox(height: 40),

          // Centered Wrapped Legend
          Wrap(
            spacing: 20,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: const [
              _LegendItem("Headache (40%)", HerLunaTheme.primaryPlum),
              _LegendItem("Cramps (30%)", HerLunaTheme.accentPlum),
              _LegendItem("Bloating (20%)", Color(0xFFE5DEE5)),
              _LegendItem("Mood (10%)", Color(0xFFD9EAE4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: HerLunaTheme.primaryPlum.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Correlation Observation",
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: HerLunaTheme.primaryPlum,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "\"Headaches tend to appear 2 days before cycles that last longer than 29 days.\"",
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CONFIDENCE LEVEL",
                  style: GoogleFonts.quicksand(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
                Text(
                  "High (84%)",
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: HerLunaTheme.primaryPlum,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- SUPPORTING COMPONENTS ---

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendItem(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AnimatedDonutChart extends StatefulWidget {
  final List<double> percentages;
  final List<Color> colors;

  const AnimatedDonutChart({
    super.key,
    required this.percentages,
    required this.colors,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _DonutPainter(
            percentages: widget.percentages,
            colors: widget.colors,
            animationValue: _animation.value,
          ),
          // Reduced size from 220 to 180 for a better "donut" ratio
          child: const SizedBox(height: 180, width: 180),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;
  final double animationValue;

  _DonutPainter({
    required this.percentages,
    required this.colors,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Thinner stroke (28 instead of 38) makes the center hole look larger and cleaner
    const strokeWidth = 28.0;

    double startAngle = -1.5708; // Start at Top

    for (int i = 0; i < percentages.length; i++) {
      final segmentTotalAngle = percentages[i] * 6.28319;
      final sweepAngle = segmentTotalAngle * animationValue;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += segmentTotalAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}

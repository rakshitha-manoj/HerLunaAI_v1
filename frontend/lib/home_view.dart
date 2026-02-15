import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.backgroundBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildMainHeroCard(),
                    const SizedBox(height: 16),
                    _buildInfoGrid(),
                    const SizedBox(height: 16),
                    _buildExpectationCard(),
                    const SizedBox(height: 16),
                    _buildTrendCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TODAY'S OBSERVATION",
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: HerLunaTheme.accentPlum,
              ),
            ),
            Text(
              "Follicular Phase",
              style: GoogleFonts.quicksand(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: HerLunaTheme.primaryPlum,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: HerLunaTheme.primaryPlum.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            LucideIcons.sparkles,
            color: HerLunaTheme.primaryPlum,
            size: 22,
          ),
        ),
      ],
    );
  }

  // --- Hero Card with Subtle Logo Watermark ---
  Widget _buildMainHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HerLunaTheme.primaryPlum,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: HerLunaTheme.primaryPlum.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/logo.png',
                  width: 220,
                  color: Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CYCLE DAY",
                    style: GoogleFonts.quicksand(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "14",
                    style: GoogleFonts.quicksand(
                      fontSize: 80,
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Current patterns suggest stable energy. This is historically your peak cognitive window.",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Equal Width Info Grid ---
  Widget _buildInfoGrid() {
    return IntrinsicHeight(
      // This is the secret to equal height without gaps
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _smallDataCard(
              LucideIcons.shieldCheck,
              "CONFIDENCE",
              "Moderate",
              "Based on logs",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _smallDataCard(
              LucideIcons.calendar,
              "NEXT WINDOW",
              "Oct 12 — 15",
              "Est. window",
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallDataCard(IconData icon, String label, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: HerLunaTheme.accentPlum),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.black38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Controlled gap between title and data
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HerLunaTheme.primaryPlum,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              color: Colors.black26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD9EAE4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EXPECTATION",
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A6A62).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Historical data indicates mild headaches may occur in the coming days. Stay mindful of hydration and rest patterns.",
            style: GoogleFonts.quicksand(
              fontSize: 15,
              height: 1.4,
              color: const Color(0xFF2D4B44),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Animated Trend Card ---
  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cycle Regularity",
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: HerLunaTheme.primaryPlum,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: HerLunaTheme.backgroundBeige,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "3 MO TREND",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: HerLunaTheme.accentPlum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SizedBox(
            height: 100,
            width: double.infinity,
            child: AnimatedTrendGraph(),
          ),
          const SizedBox(height: 16),
          Text(
            "Insight: Cycle length variability has decreased by 12% recently.",
            style: GoogleFonts.quicksand(
              fontSize: 12,
              height: 1.3,
              fontStyle: FontStyle.italic,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ANIMATION CLASSES (Outside of HomeView) ---

class AnimatedTrendGraph extends StatefulWidget {
  const AnimatedTrendGraph({super.key});

  @override
  State<AnimatedTrendGraph> createState() => _AnimatedTrendGraphState();
}

class _AnimatedTrendGraphState extends State<AnimatedTrendGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
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
      builder: (context, child) =>
          CustomPaint(painter: _FlowingLinePainter(_animation.value)),
    );
  }
}

class _FlowingLinePainter extends CustomPainter {
  final double progress;
  _FlowingLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = HerLunaTheme.primaryPlum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.15,
      size.width,
      size.height * 0.85,
    );

    final pathMetrics = path.computeMetrics();
    for (var metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlowingLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

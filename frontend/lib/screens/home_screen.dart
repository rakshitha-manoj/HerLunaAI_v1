import 'package:flutter/material.dart';

// Import your respective screen files here!
// (Make sure these files exist and the paths are correct)
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'planner_screen.dart';
import 'settings_screen.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);

// Expectation Card Colors
const Color _expectBg = Color(0xFFE8F5F1);
const Color _expectTextDark = Color(0xFF2B6B66);
const Color _expectTextLight = Color(0xFF5A9A94);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Home is index 0
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildStatCards(),
                  const SizedBox(height: 16),
                  _buildExpectationCard(),
                  const SizedBox(height: 16),
                  _buildChartCard(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ==========================================
  // 1. HEADER WIDGET
  // ==========================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Good Evening, rr",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Here's your current cycle intelligence.",
          style: TextStyle(fontSize: 16, color: _textGray.withOpacity(0.9)),
        ),
      ],
    );
  }

  // ==========================================
  // 2. HERO CARD (Today's Observation)
  // ==========================================
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryMuted,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 35,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S OBSERVATION",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Menstrual Phase",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "CYCLE DAY",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  "1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "On this first day of your cycle, your hormone levels are at their lowest, which can result in significant fatigue and a natural pull toward introspection. As a student, you may find your cognitive stamina feels limited today, making it an ideal time to prioritize restorative rest over rigorous academic demands.",
                    style: TextStyle(
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
    );
  }

  // ==========================================
  // 3. TWO STAT CARDS
  // ==========================================
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallCard(
            icon: Icons.verified_user_outlined,
            title: "CONFIDENCE",
            value: "Moderate",
            subtitle: "Based on recent logs",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallCard(
            icon: Icons.calendar_today_outlined,
            title: "NEXT WINDOW",
            value: "Apr 1 — 5",
            subtitle: "Estimated range",
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _primaryMuted),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: _textGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: _primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: _textGray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. EXPECTATION CARD
  // ==========================================
  Widget _buildExpectationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _expectBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EXPECTATION",
            style: TextStyle(
              color: _expectTextLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Over the next few days, you might experience lingering physical discomfort or fluctuating moods as your body begins its renewal process. To manage this effectively, focus on staying hydrated and choosing gentle, low-pressure study environments that honor your body's need for a slower pace.",
            style: TextStyle(
              color: _expectTextDark,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. CYCLE REGULARITY CHART CARD
  // ==========================================
  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Cycle Regularity",
                style: TextStyle(
                  color: _primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _bgWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "3 MONTH TREND",
                  style: TextStyle(
                    color: _textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(painter: _SparklinePainter()),
          ),
          const SizedBox(height: 24),
          const Text(
            "Cycle length variability has decreased by 12% recently.",
            style: TextStyle(color: _textGray, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. BOTTOM NAVIGATION BAR (WITH ROUTING)
  // ==========================================
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _primaryDark,
          unselectedItemColor: const Color(0xFFC4BCC8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.8,
          ),
          elevation: 0,
          onTap: (index) {
            // Do nothing if we're already on this tab
            if (index == _currentIndex) return;

            Widget nextScreen;
            switch (index) {
              case 0:
                nextScreen = const HomeScreen();
                break;
              case 1:
                nextScreen = const CalendarScreen();
                break;
              case 2:
                nextScreen = const InsightsScreen();
                break;
              case 3:
                nextScreen = const PlannerScreen();
                break;
              case 4:
                nextScreen = const SettingsScreen();
                break;
              default:
                return;
            }

            // Zero-duration transition makes it feel like a real tab switch
            // instead of a sliding new page.
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => nextScreen,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 28),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 26),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined, size: 28),
              label: "Insights",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded, size: 28),
              label: "Planner",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 28),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER FOR SPARKLINE CHART
// ==========================================
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()
      ..color = _primaryMuted
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint axisPaint = Paint()
      ..color = _lightGray.withOpacity(0.5)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    Path path = Path();
    path.moveTo(0, size.height * 0.85);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.85,
      size.width * 0.45,
      size.height * 0.05,
      size.width * 0.65,
      size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.15,
      size.width,
      size.height * 0.85,
    );

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

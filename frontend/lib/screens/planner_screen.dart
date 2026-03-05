import 'package:flutter/material.dart';

// Import your respective screen files here for the BottomNav
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);
const Color _cardBg = Color(0xFFFFFFFF);

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // Navigation Index (Planner is index 3)
  final int _currentIndex = 3;

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
                  _buildNextPeriodCard(),
                  const SizedBox(height: 16),
                  _buildNextTransitionCard(),
                  const SizedBox(height: 16),
                  _buildOutlookCard(
                    icon: Icons.bolt,
                    title: "Energy Outlook",
                    text:
                        "Expect a natural surge in energy over the next 4 days. This is an ideal time for high-intensity workouts or demanding projects.",
                  ),
                  const SizedBox(height: 16),
                  _buildOutlookCard(
                    icon: Icons.show_chart,
                    title: "Stress Outlook",
                    text:
                        "Historical data suggests a potential stress cluster starting in 6 days. Prioritize recovery routines this weekend.",
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "PREPARATION",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: _textGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreparationList(),
                  const SizedBox(height: 32),
                  const Text(
                    "NEXT 7 DAYS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: _textGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(),
                  const SizedBox(height: 40), // Bottom padding
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
          "Planner",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Prepare for what's next",
          style: TextStyle(fontSize: 16, color: _textGray.withOpacity(0.9)),
        ),
      ],
    );
  }

  // ==========================================
  // 2. HERO CARD (NEXT PERIOD WINDOW)
  // ==========================================
  Widget _buildNextPeriodCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryMuted,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Faint Background Graphic (Simulating the faint calendar shape in the screenshot)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.calendar_view_month,
              size: 200,
              color: Colors.white.withOpacity(0.04),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NEXT PERIOD WINDOW",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Apr 1 — 5",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Based on your 28-day average cycle.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),

                // Confidence Divider and text
                Container(
                  height: 1,
                  width: double.infinity,
                  color: Colors.white.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "CONFIDENCE: 94%",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. NEXT TRANSITION CARD
  // ==========================================
  Widget _buildNextTransitionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NEXT TRANSITION",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: _textGray,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    "Follicular Phase",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: _textGray.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
          const Text(
            "in 4d",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _primaryMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. OUTLOOK CARDS
  // ==========================================
  Widget _buildOutlookCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: _primaryMuted),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(fontSize: 15, height: 1.5, color: _textGray),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. PREPARATION LIST
  // ==========================================
  Widget _buildPreparationList() {
    return Column(
      children: [
        _buildPrepItem(
          icon: Icons.coffee_outlined,
          iconColor: const Color(0xFFE88A30),
          bgColor: const Color(0xFFFDECDA),
          text: "Increase magnesium intake starting tomorrow.",
        ),
        const SizedBox(height: 12),
        _buildPrepItem(
          icon: Icons.dark_mode_outlined,
          iconColor: const Color(0xFF6B5372),
          bgColor: const Color(0xFFEBE6F5),
          text: "Aim for 8+ hours of sleep to buffer upcoming phase shift.",
        ),
        const SizedBox(height: 12),
        _buildPrepItem(
          icon: Icons.auto_awesome_outlined,
          iconColor: const Color(0xFF4BA87D),
          bgColor: const Color(0xFFE3F2EB),
          text: "Schedule deep-focus work for Tuesday's peak.",
        ),
      ],
    );
  }

  Widget _buildPrepItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: _primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. NEXT 7 DAYS TIMELINE
  // ==========================================
  // ==========================================
  // 6. NEXT 7 DAYS TIMELINE (FIXED OVERFLOW)
  // ==========================================
  Widget _buildTimeline() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate a safe minimum width for the 7 items to breathe.
        // If the screen is narrower than 360px, we force the row to be 360px
        // and let the FittedBox scale it down smoothly to fit the screen.
        final double safeWidth = constraints.maxWidth < 360
            ? 360
            : constraints.maxWidth;

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: safeWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayNode("TODAY", "5", isActive: true, hasDot: false),
                _buildDayNode("FRI", "6", isActive: false, hasDot: false),
                _buildDayNode("SAT", "7", isActive: false, hasDot: false),
                _buildDayNode("SUN", "8", isActive: false, hasDot: true),
                _buildDayNode("MON", "9", isActive: false, hasDot: false),
                _buildDayNode("TUE", "10", isActive: false, hasDot: true),
                _buildDayNode("WED", "11", isActive: false, hasDot: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayNode(
    String dayName,
    String dateNum, {
    required bool isActive,
    required bool hasDot,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevents vertical unbound errors
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _textGray.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _primaryMuted : Colors.white,
            shape: BoxShape.circle,
            border: isActive ? null : Border.all(color: Colors.transparent),
          ),
          child: Text(
            dateNum,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : _primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Indicator Dot
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: hasDot ? _primaryMuted : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

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

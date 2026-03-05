import 'package:flutter/material.dart';
import 'dart:math';

// Import your respective screen files here for the BottomNav
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'planner_screen.dart';
import 'settings_screen.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);
const Color _cardBg = Color(0xFFFFFFFF);

// Specific Insight Colors
const Color _stressOrange = Color(0xFFE87A30);
const Color _stressLightBg = Color(0xFFFCF6EF);

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Navigation Index (Insights is index 2)
  final int _currentIndex = 2;

  // Tab State: 0 = Cycle, 1 = Energy, 2 = Stress
  int _selectedTab = 0;

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
                  _buildSegmentedControl(),
                  const SizedBox(height: 24),

                  // Conditional Content based on selected tab
                  if (_selectedTab == 0) _buildCycleTab(),
                  if (_selectedTab == 1) _buildEnergyTab(),
                  if (_selectedTab == 2) _buildStressTab(),

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
          "Intelligence",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Long-term patterns & behavior",
          style: TextStyle(fontSize: 16, color: _textGray.withOpacity(0.9)),
        ),
      ],
    );
  }

  // ==========================================
  // 2. SEGMENTED CONTROL (TABS)
  // ==========================================
  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("CYCLE", 0)),
          Expanded(child: _buildTabButton("ENERGY", 1)),
          Expanded(child: _buildTabButton("STRESS", 2)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _primaryMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : _textGray.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. CYCLE TAB CONTENT
  // ==========================================
  Widget _buildCycleTab() {
    return Column(
      children: [
        // Cycle History Bar Chart Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Cycle History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                  Text(
                    "LAST 5 CYCLES",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _textGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Bar Chart
              SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("Oct", 0.8),
                    _buildBar("Nov", 0.85),
                    _buildBar("Dec", 0.75),
                    _buildBar("Jan", 0.8),
                    _buildBar("Feb", 0.95),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats Row (Avg Length & Variability)
        Row(
          children: [
            Expanded(child: _buildStatCard("AVG LENGTH", "28.4 Days")),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard("VARIABILITY", "±1.2 Days")),
          ],
        ),
        const SizedBox(height: 16),

        // Phase Distribution Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Phase Distribution",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  // Donut Chart
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CustomPaint(painter: _DonutChartPainter()),
                  ),
                  const SizedBox(width: 32),
                  // Legend
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendItem("Menstrual", "5d", _primaryMuted),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          "Follicular",
                          "9d",
                          const Color(0xFFD4C9DA),
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem("Ovulatory", "3d", _stressOrange),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          "Luteal",
                          "11d",
                          const Color(0xFFE2F0EA),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Cycle Stability Card
        _buildInfoCard(
          icon: Icons.show_chart,
          title: "Cycle Stability",
          description:
              "Your cycle length has remained consistent across recent months, indicating high physiological stability.",
        ),
      ],
    );
  }

  Widget _buildBar(String label, double fillPercent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 140 * fillPercent,
          decoration: BoxDecoration(
            color: _primaryMuted,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textGray.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: _textGray.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: _textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. ENERGY TAB CONTENT
  // ==========================================
  Widget _buildEnergyTab() {
    return Column(
      children: [
        // Energy Trends Line Chart
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Energy Trends",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                  Text(
                    "LAST 30 DAYS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _textGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    color: _primaryMuted,
                    isFilled: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.bolt,
          title: "PEAK ENERGY",
          description: "Typically occurs during Ovulatory Phase",
          isSmallTitle: true,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          icon: Icons.info_outline,
          title: "OBSERVATION",
          description: "Energy levels appear stable over recent weeks.",
          isSmallTitle: true,
        ),
      ],
    );
  }

  // ==========================================
  // 5. STRESS TAB CONTENT
  // ==========================================
  Widget _buildStressTab() {
    return Column(
      children: [
        // Stress Patterns Line Chart
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stress Patterns",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                  Text(
                    "LAST 30 DAYS",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _textGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    color: _stressOrange,
                    isFilled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stress Insight Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _stressLightBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    color: _stressOrange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "STRESS INSIGHT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _stressOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Stress levels have been higher than usual recently, potentially impacting your sleep quality. Consider mindfulness practices during your Luteal phase.",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9E4B18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SHARED WIDGETS
  // ==========================================
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    bool isSmallTitle = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _bgWhite, shape: BoxShape.circle),
            child: Icon(icon, color: _primaryMuted, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSmallTitle)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _textGray.withOpacity(0.8),
                    ),
                  )
                else
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primaryDark,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isSmallTitle ? _primaryDark : _textGray,
                    fontWeight: isSmallTitle
                        ? FontWeight.w500
                        : FontWeight.normal,
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
  // BOTTOM NAVIGATION BAR
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

// ==========================================
// CUSTOM PAINTER: DONUT CHART
// ==========================================
class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 24.0;
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Angles based on the screenshot distribution
    // Menstrual (Purple) ~ 15%
    paint.color = _primaryMuted;
    canvas.drawArc(rect, -pi / 2, pi * 0.4, false, paint);

    // Follicular (Light Purple) ~ 35%
    paint.color = const Color(0xFFD4C9DA);
    canvas.drawArc(rect, -pi / 2 + (pi * 0.45), pi * 0.8, false, paint);

    // Ovulatory (Orange) ~ 10%
    paint.color = _stressOrange;
    canvas.drawArc(rect, -pi / 2 + (pi * 1.3), pi * 0.2, false, paint);

    // Luteal (Light Green) ~ 40%
    paint.color = const Color(0xFFE2F0EA);
    canvas.drawArc(rect, -pi / 2 + (pi * 1.55), pi * 0.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// CUSTOM PAINTER: LINE TREND CHART
// ==========================================
class _LineChartPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _LineChartPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    // Hardcoded data points to mimic the screenshot's jagged line trend
    List<double> dataPoints = [
      0.4,
      0.9,
      0.6,
      0.5,
      0.8,
      0.95,
      0.8,
      0.5,
      0.9,
      0.8,
      0.45,
      0.9,
      0.85,
      0.85,
      0.95,
      0.55,
      0.4,
      0.6,
      0.5,
      0.65,
      0.55,
      0.95,
      0.8,
    ];

    double stepX = size.width / (dataPoints.length - 1);

    Path path = Path();
    path.moveTo(0, size.height - (dataPoints[0] * size.height));

    for (int i = 1; i < dataPoints.length; i++) {
      // Adding a little smoothing with quadratic bezier
      double x = i * stepX;
      double y = size.height - (dataPoints[i] * size.height);
      double prevX = (i - 1) * stepX;
      double prevY = size.height - (dataPoints[i - 1] * size.height);

      path.quadraticBezierTo(prevX + (stepX / 2), prevY, x, y);
    }

    // Draw Fill Gradient (Only for Energy Tab)
    if (isFilled) {
      Path fillPath = Path.from(path);
      fillPath.lineTo(size.width, size.height);
      fillPath.lineTo(0, size.height);
      fillPath.close();

      Paint fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw Line Stroke
    Paint strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

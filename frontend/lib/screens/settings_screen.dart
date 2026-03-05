import 'package:flutter/material.dart';

// Import your respective screen files here for the BottomNav
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'insights_screen.dart';
import 'planner_screen.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

// Services
import '../services/api_service.dart';
import '../services/storage_service.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);
const Color _cardBg = Color(0xFFFFFFFF);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Navigation Index (Settings is index 4)
  final int _currentIndex = 4;

  // Toggle States
  bool _periodReminders = true;
  bool _loggingReminders = true;
  bool _cycleInsights = true;

  // Profile Data (loaded from storage)
  String _name = '';
  String _email = '';
  String _ageRange = '';
  String _activity = '';
  String _storageMode = 'Local Only';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await StorageService.getName();
    final email = await StorageService.getEmail();
    final age = await StorageService.getAgeRange();
    final activity = await StorageService.getActivity();
    final mode = await StorageService.getStorageMode();
    if (!mounted) return;
    setState(() {
      _name = name ?? '';
      _email = email ?? '';
      _ageRange = age ?? '';
      _activity = activity ?? '';
      _storageMode = mode == 'cloud' ? 'Cloud Sync' : 'Local Only';
    });
  }

  Future<void> _logout() async {
    ApiService().clearToken();
    await StorageService.clearAll();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  Future<void> _clearLocalData() async {
    await StorageService.clearAll();
    ApiService().clearToken();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local data cleared'), backgroundColor: Color(0xFF6E5C77)),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  Future<void> _resetOnboarding() async {
    await StorageService.setOnboardingComplete(false);
    ApiService().clearToken();
    await StorageService.clearAll();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

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
                  const SizedBox(height: 32),

                  _buildSectionHeader("PROFILE INFORMATION"),
                  _buildProfileSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader("DATA & PRIVACY"),
                  _buildDataPrivacySection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader("CYCLE BASELINE"),
                  _buildCycleBaselineSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader("NOTIFICATIONS"),
                  _buildNotificationsSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader("ACCOUNT ACTIONS"),
                  _buildAccountActions(),
                  const SizedBox(height: 48),

                  _buildFooter(),
                  const SizedBox(height: 40),
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
  // WIDGETS
  // ==========================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Settings",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Manage your account & preferences",
          style: TextStyle(fontSize: 16, color: _textGray.withOpacity(0.9)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: _textGray,
        ),
      ),
    );
  }

  // --- SECTIONS ---

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: "Name",
            trailingText: _name.isNotEmpty ? _name : '—',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.mail_outline,
            title: "Email",
            trailingText: _email.isNotEmpty ? _email : '—',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.show_chart,
            title: "Age Range",
            trailingText: _ageRange.isNotEmpty ? _ageRange : '—',
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.show_chart,
            title: "Activity Pattern",
            trailingText: _activity.isNotEmpty ? _activity : '—',
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.storage,
            title: "Storage Mode",
            trailingText: _storageMode,
            iconBgColor: _primaryMuted,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(icon: Icons.lock_outline, title: "Privacy Policy"),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "How Data is Used",
          ),
        ],
      ),
    );
  }

  Widget _buildCycleBaselineSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.calendar_today_outlined,
            title: "Avg Cycle Length",
            trailingText: "28 Days",
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.calendar_today_outlined,
            title: "Last Period Start",
            trailingText: "2026-03-04",
          ),
          const SizedBox(height: 24),
          _buildSettingsTile(
            icon: Icons.show_chart,
            title: "Irregular Cycles",
            trailingText: "No",
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: "Period Reminders",
            value: _periodReminders,
            onChanged: (val) => setState(() => _periodReminders = val),
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: "Logging Reminders",
            value: _loggingReminders,
            onChanged: (val) => setState(() => _loggingReminders = val),
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: "Cycle Insights",
            value: _cycleInsights,
            onChanged: (val) => setState(() => _cycleInsights = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: _clearLocalData,
          child: _buildActionButton(
            label: "Clear Local Data",
            icon: Icons.delete_outline,
            textColor: const Color(0xFFE53935),
            bgColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _resetOnboarding,
          child: _buildActionButton(
            label: "Reset Onboarding",
            icon: Icons.autorenew,
            textColor: _primaryDark,
            bgColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _logout,
          child: _buildActionButton(
            label: "Logout",
            icon: Icons.logout,
            textColor: Colors.white,
            bgColor: _primaryMuted,
            isSolid: true,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          "HERLUNA AI V1.0.4",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: _textGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Crafted with intelligence for you.",
          style: TextStyle(fontSize: 12, color: _textGray.withOpacity(0.6)),
        ),
      ],
    );
  }

  // --- HELPER COMPONENTS ---

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor ?? _bgWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor ?? _primaryDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText,
            style: const TextStyle(fontSize: 14, color: _textGray),
          ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, size: 20, color: _lightGray),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _bgWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: _primaryDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryDark,
            ),
          ),
        ),
        SizedBox(
          height: 30, // constrain switch height
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primaryMuted,
            inactiveTrackColor: _lightGray,
            inactiveThumbColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
    bool isSolid = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: textColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
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

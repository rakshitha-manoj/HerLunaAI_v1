import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/insights_screen.dart';
import '../screens/planner_screen.dart';
import '../screens/settings_screen.dart';

/// Main navigation shell with 5-tab bottom navigation.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomePage(),
    CalendarScreen(),
    SizedBox(), // Log placeholder (center tab)
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) {
              if (i == 2) {
                // Center "Log" tab — show bottom sheet
                _showLogSheet(context);
                return;
              }
              setState(() => _selectedIndex = i);
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Calendar'),
              BottomNavigationBarItem(
                icon:
                    Icon(Icons.add_circle, size: 40, color: AppColors.primaryMuted),
                label: 'Log',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.psychology_outlined), label: 'AI'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lavender,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Log',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            _logOption(Icons.water_drop_outlined, 'Log Period'),
            _logOption(Icons.favorite_outline, 'Log Mood'),
            _logOption(Icons.nightlight_outlined, 'Log Sleep'),
            _logOption(Icons.directions_run_outlined, 'Log Activity'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _logOption(IconData icon, String label) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lavender.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.primaryMuted),
      onTap: () => Navigator.pop(context),
    );
  }
}

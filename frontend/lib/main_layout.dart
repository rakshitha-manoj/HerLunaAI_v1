import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';
import 'home_view.dart';
import 'calendar_view.dart';
import 'insights_view.dart';
import 'guidance_view.dart';
import 'settings_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Placeholder screens - We will build 'HomeView' next
  final List<Widget> _pages = [
    const HomeView(), // Now the Today View is live
    const CalendarView(),
    const InsightsView(),
    const GuidanceView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        // Subtle top border to separate from content
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: HerLunaTheme.primaryPlum.withOpacity(
            0.15,
          ), // The highlight pill
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(LucideIcons.calendar),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.sparkles),
              label: 'Insights',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.heart),
              label: 'Guidance',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

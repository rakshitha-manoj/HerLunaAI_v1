import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'splash_screen.dart';

void main() async {
  // Required for accessing SharedPreferences before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved theme preference (default to false/light if not found)
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(HerLunaApp(isDarkInit: isDark));
}

class HerLunaApp extends StatefulWidget {
  final bool isDarkInit;
  const HerLunaApp({super.key, required this.isDarkInit});

  // Static helper to allow descendant widgets to trigger a theme change
  static _HerLunaAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_HerLunaAppState>()!;

  @override
  State<HerLunaApp> createState() => _HerLunaAppState();
}

class _HerLunaAppState extends State<HerLunaApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    // Initialize theme based on the saved value passed from main()
    _themeMode = widget.isDarkInit ? ThemeMode.dark : ThemeMode.light;
  }

  /// Public method to switch themes and save to local storage
  void toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerLuna AI',
      debugShowCheckedModeBanner: false,
      // Provide both configurations
      theme: HerLunaTheme.lightTheme,
      darkTheme: HerLunaTheme.darkTheme,
      // Current active mode
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}

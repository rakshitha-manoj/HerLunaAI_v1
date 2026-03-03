import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HerLunaApp());
}

class HerLunaApp extends StatelessWidget {
  const HerLunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'HerLuna',
        debugShowCheckedModeBanner: false,
        theme: HerLunaTheme.lightTheme,
        home: const AppEntryPoint(),
      ),
    );
  }
}

/// Determines initial screen based on stored mode selection.
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.initialize();

    // Check if user has a stored token and mode selected
    final hasMode = provider.storageMode.isNotEmpty;
    final hasUser = provider.currentUser != null;

    setState(() {
      _isAuthenticated = hasMode && hasUser;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: HerLunaTheme.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: HerLunaTheme.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    // Authenticated users go to main app, others see splash
    return _isAuthenticated ? const MainShell() : const SplashScreen();
  }
}

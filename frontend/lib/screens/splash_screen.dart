import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import '../core/spacing.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../navigation/main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash briefly

    final token = await StorageService.getToken();
    final userId = await StorageService.getUserId();
    final onboarded = await StorageService.isOnboardingComplete();

    if (!mounted) return;

    if (token != null && userId != null && onboarded) {
      // Restore token to ApiService
      ApiService().setToken(token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logo (Using Constant)
              Image.asset(
                AppConstants.logoPath,
                width: 140,
                fit: BoxFit.contain,
              ),

              AppSpacing.verticalMedium, // 32.0

              // 2. App Title (Using Palette)
              const Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryMuted,
                  letterSpacing: 0.8,
                ),
              ),

              AppSpacing.verticalSmall, // 16.0

              // 3. Tagline (Using Palette)
              const Text(
                AppConstants.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryDark,
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
              ),

              AppSpacing.verticalLarge, // 48.0

              // 4. Loader (Using Palette)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
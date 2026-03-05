import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/constants.dart';
import '../core/spacing.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
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
    await Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();
    final onboarded = await StorageService.isOnboardingComplete();

    if (!mounted) return;

    if (token != null && onboarded) {
      ApiService().setToken(token);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                width: 140, // You can also move this to AppConstants
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
                  color: AppColors.primaryDark, // Using the deep purple for readability
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
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'profile_setup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HerLunaTheme.horizontalPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: HerLunaTheme.heroGradient,
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Heading
              const Text(
                'Welcome to HerLuna',
                style: HerLunaTheme.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Personalized cycle and\nlifestyle intelligence.',
                style: HerLunaTheme.bodyLarge.copyWith(
                  color: HerLunaTheme.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Create Profile
              HerLunaButton(
                text: 'Create Profile',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Login
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(isLogin: true),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 24),
              // Disclaimer
              Text(
                'HerLuna provides probabilistic insights,\nnot medical diagnosis.',
                style: HerLunaTheme.bodySmall.copyWith(
                  color: HerLunaTheme.textSecondary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

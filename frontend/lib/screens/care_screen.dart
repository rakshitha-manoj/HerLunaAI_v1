import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: HerLunaTheme.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Care', style: HerLunaTheme.heading2),
              const SizedBox(height: 8),
              Text(
                'Resources and support for your wellbeing.',
                style: HerLunaTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ── Nearby Gynecologist ────────────────────────────────
              _careSection(
                icon: Icons.local_hospital_outlined,
                title: 'Nearby Gynecologist',
                description:
                    'Find healthcare professionals in your area.',
                actionText: 'Search Nearby',
                onTap: () {
                  // Would trigger healthcare API
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Searching nearby providers...'),
                      backgroundColor: HerLunaTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ── Educational Resources ─────────────────────────────
              _careSection(
                icon: Icons.menu_book_outlined,
                title: 'Educational Resources',
                description:
                    'Learn about cycle phases, nutrition, and wellness.',
                actionText: 'Explore',
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // ── Emergency Contact ─────────────────────────────────
              _careSection(
                icon: Icons.phone_outlined,
                title: 'Emergency Contact',
                description:
                    'Quick access to emergency support and helplines.',
                actionText: 'View Contacts',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // ── Wellness Tips ─────────────────────────────────────
              Text(
                'Wellness Tips',
                style: HerLunaTheme.heading3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              _tipCard(
                '💧',
                'Stay Hydrated',
                'Aim for 8 glasses of water daily, adjusting for activity level.',
              ),
              const SizedBox(height: 8),
              _tipCard(
                '🧘',
                'Mindful Movement',
                'Gentle stretching or yoga can help manage cycle-related discomfort.',
              ),
              const SizedBox(height: 8),
              _tipCard(
                '😴',
                'Sleep Consistency',
                'Regular sleep patterns support hormonal balance and mood stability.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _careSection({
    required IconData icon,
    required String title,
    required String description,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return HerLunaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: HerLunaTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: HerLunaTheme.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: HerLunaTheme.heading3.copyWith(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: HerLunaTheme.bodyMedium),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: HerLunaTheme.primary,
                side: const BorderSide(color: HerLunaTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(HerLunaTheme.buttonRadius),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(actionText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String emoji, String title, String description) {
    return HerLunaCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: HerLunaTheme.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: HerLunaTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

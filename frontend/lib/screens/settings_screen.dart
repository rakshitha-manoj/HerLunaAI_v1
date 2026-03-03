import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: HerLunaTheme.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Profile ───────────────────────────────────────
                  _settingsGroup('Profile', [
                    _settingsTile(
                      icon: Icons.person_outline,
                      title: 'Account',
                      subtitle: provider.currentUser?.email ?? 'Not signed in',
                    ),
                    _settingsTile(
                      icon: Icons.badge_outlined,
                      title: 'Full Name',
                      subtitle: provider.currentUser?.email.split('@').first ?? '',
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Data Mode ─────────────────────────────────────
                  _settingsGroup('Data Mode', [
                    _settingsTile(
                      icon: provider.isCloudMode
                          ? Icons.cloud_outlined
                          : Icons.phone_android,
                      title: 'Storage Mode',
                      subtitle: provider.isCloudMode ? 'Cloud' : 'Local',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: HerLunaTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.isCloudMode ? 'Cloud' : 'Local',
                          style: HerLunaTheme.bodySmall.copyWith(
                            color: HerLunaTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Preferences ───────────────────────────────────
                  _settingsGroup('Preferences', [
                    _settingsTile(
                      icon: Icons.child_care_outlined,
                      title: 'Young Girl Mode',
                      subtitle: provider.isYoungGirlMode ? 'On' : 'Off',
                      trailing: Switch(
                        value: provider.isYoungGirlMode,
                        onChanged: (v) => provider.setYoungGirlMode(v),
                        activeColor: HerLunaTheme.primary,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Notifications ─────────────────────────────────
                  _settingsGroup('Notifications', [
                    _settingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      subtitle: 'Receive cycle and wellness reminders',
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: HerLunaTheme.primary,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // ── Privacy ───────────────────────────────────────
                  _settingsGroup('Privacy', [
                    _settingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'How we protect your data',
                    ),
                    _settingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Usage terms and conditions',
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // ── Logout ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        await provider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const SplashScreen()),
                            (_) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HerLunaTheme.error,
                        side: const BorderSide(color: HerLunaTheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(HerLunaTheme.buttonRadius),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Version
                  Center(
                    child: Text(
                      'HerLuna v2.0.0',
                      style: HerLunaTheme.bodySmall.copyWith(
                        color: HerLunaTheme.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _settingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: HerLunaTheme.labelText.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: HerLunaTheme.cardColor,
            borderRadius: BorderRadius.circular(HerLunaTheme.cardRadius),
            boxShadow: HerLunaTheme.cardShadow,
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          const Divider(
                              height: 1,
                              indent: 56,
                              color: HerLunaTheme.divider),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: HerLunaTheme.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: HerLunaTheme.bodyLarge.copyWith(fontSize: 14)),
                Text(subtitle, style: HerLunaTheme.bodySmall),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

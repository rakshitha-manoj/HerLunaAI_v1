import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _displayName = 'Alex Rivera';
  String _displayEmail = 'Pro Member · Cloud Mode';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await StorageService.getEmail();
    final mode = await StorageService.getStorageMode();
    if (email != null && mounted) {
      setState(() {
        _displayName = email.split('@').first;
        _displayEmail = 'Member · ${mode == 'local' ? 'Local' : 'Cloud'} Mode';
      });
    }
  }

  Future<void> _logout() async {
    ApiService().clearToken();
    await StorageService.clearAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header
            _buildProfileHeader(),

            AppSpacing.verticalLarge,

            // 2. Account Section
            _buildSectionTitle("Account"),
            _buildSettingsTile(Icons.person_outline, "Personal Information"),
            _buildSettingsTile(Icons.notifications_none, "Notification Preferences"),
            _buildSettingsTile(Icons.lock_outline, "Privacy & Data Storage"),

            AppSpacing.verticalMedium,

            // 3. App Settings Section
            _buildSectionTitle("App Settings"),
            _buildSettingsTile(Icons.auto_awesome_outlined, "AI Insight Calibration"),
            _buildSettingsTile(Icons.sync, "Sync with Apple Health / Google Fit"),
            _buildSettingsTile(Icons.palette_outlined, "Theme Customization"),

            AppSpacing.verticalMedium,

            // 4. Support Section
            _buildSectionTitle("Support"),
            _buildSettingsTile(Icons.help_outline, "Help Center"),
            _buildSettingsTile(Icons.description_outlined, "Terms of Service"),

            AppSpacing.verticalLarge,

            // 5. Logout Button
            Center(
              child: TextButton(
                onPressed: _logout,
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const Center(
              child: Text(
                "Version 1.0.2",
                style: TextStyle(color: AppColors.primaryMuted, fontSize: 12),
              ),
            ),
            AppSpacing.verticalLarge,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.lavender,
            child: Icon(Icons.person, size: 35, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 16),
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
                Text(
                  _displayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                Text(
                  _displayEmail,
                  style: const TextStyle(color: AppColors.primaryMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryMuted),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lavender.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, color: AppColors.primaryDark),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primaryMuted),
        onTap: () {},
      ),
    );
  }
}
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

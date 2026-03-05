import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'cycle_baseline_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String _selectedMode = 'cloud';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HerLunaTheme.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Choose how your\ndata is handled',
                style: HerLunaTheme.heading1,
              ),
              const SizedBox(height: 36),
              // Cloud Mode Card
              _ModeCard(
                icon: Icons.cloud_outlined,
                title: 'Cloud Mode',
                description: 'Secure backup and multi-device access',
                isSelected: _selectedMode == 'cloud',
                onTap: () => setState(() => _selectedMode = 'cloud'),
              ),
              const SizedBox(height: 12),
              // Local Mode Card
              _ModeCard(
                icon: Icons.phone_android_outlined,
                title: 'Local Mode',
                description: 'Data stays only on this device',
                isSelected: _selectedMode == 'local',
                onTap: () => setState(() => _selectedMode = 'local'),
              ),
              const Spacer(),
              HerLunaButton(
                text: 'Continue',
                onPressed: () async {
                  final provider =
                      Provider.of<AppProvider>(context, listen: false);
                  await provider.setStorageMode(_selectedMode);
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CycleBaselineScreen(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HerLunaCard(
      isSelected: isSelected,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? HerLunaTheme.primary.withOpacity(0.1)
                  : HerLunaTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? HerLunaTheme.primary
                  : HerLunaTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HerLunaTheme.heading3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(description, style: HerLunaTheme.bodyMedium),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle, color: HerLunaTheme.primary, size: 22),
        ],
      ),
    );
  }
}

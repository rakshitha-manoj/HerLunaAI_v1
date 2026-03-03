import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'mode_selection_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isLogin;
  const ProfileSetupScreen({super.key, this.isLogin = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedAge = '18–24';
  String _selectedActivity = 'Mixed Routine';
  bool _isLoading = false;

  final List<String> _ageRanges = ['Under 18', '18–24', '25–34', '35–44', '45+'];
  final List<Map<String, dynamic>> _activities = [
    {'label': 'Student', 'icon': Icons.school_outlined},
    {'label': 'Athlete', 'icon': Icons.fitness_center_outlined},
    {'label': 'Working Professional', 'icon': Icons.work_outline},
    {'label': 'Mixed Routine', 'icon': Icons.shuffle_outlined},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    bool success;
    if (widget.isLogin) {
      success = await provider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await provider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      if (widget.isLogin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
          (_) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
        );
      }
    }
  }

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: HerLunaTheme.horizontalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Header
              Text(
                widget.isLogin
                    ? 'Welcome back'
                    : "Let's personalize\nyour experience",
                style: HerLunaTheme.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                widget.isLogin
                    ? 'Sign in to your account.'
                    : 'This helps us tailor your insights.',
                style: HerLunaTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // ── Basic Information ────────────────────────────────────
              if (!widget.isLogin) ...[
                _sectionLabel('Basic Information'),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Full name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: HerLunaTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (!widget.isLogin) ...[
                const SizedBox(height: 32),
                // ── Age Range ──────────────────────────────────────────
                _sectionLabel('Age Range'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _ageRanges.map((age) {
                    return HerLunaChip(
                      label: age,
                      isSelected: _selectedAge == age,
                      onTap: () => setState(() => _selectedAge = age),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                // ── Activity Pattern ───────────────────────────────────
                _sectionLabel('Activity Pattern'),
                const SizedBox(height: 12),
                ...(_activities.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: HerLunaCard(
                        isSelected: _selectedActivity == a['label'],
                        onTap: () =>
                            setState(() => _selectedActivity = a['label']),
                        child: Row(
                          children: [
                            Icon(
                              a['icon'] as IconData,
                              color: _selectedActivity == a['label']
                                  ? HerLunaTheme.primary
                                  : HerLunaTheme.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              a['label'],
                              style: HerLunaTheme.bodyLarge.copyWith(
                                fontWeight: _selectedActivity == a['label']
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
              ],

              const SizedBox(height: 40),
              HerLunaButton(
                text: widget.isLogin ? 'Sign In' : 'Continue',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: HerLunaTheme.heading3.copyWith(fontSize: 16),
    );
  }
}

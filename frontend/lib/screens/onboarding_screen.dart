import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../navigation/main_shell.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Collected data across slides
  String _name = '';
  String _email = '';
  String _password = '';
  String _ageRange = '';
  String _activityLevel = '';
  String _storageMode = 'cloud';
  int _cycleLength = 28;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final api = ApiService();
      final result = await api.register(
        email: _email,
        password: _password,
        name: _name,
        storageMode: _storageMode,
      );

      // Store credentials locally
      await StorageService.saveToken(result['access_token']);
      await StorageService.saveUserId(result['user']['id']);
      await StorageService.saveEmail(_email);
      await StorageService.saveStorageMode(_storageMode);
      await StorageService.setOnboardingComplete(true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 5,
              backgroundColor: AppColors.lavender,
              color: AppColors.primaryMuted,
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _ConsentSlide(
                    onNext: _nextPage,
                    onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  ),
                  _BasicInfoSlide(
                    onNext: _nextPage,
                    onNameChanged: (v) => _name = v,
                  ),
                  _AgeActivitySlide(
                    onNext: _nextPage,
                    onAgeChanged: (v) => _ageRange = v,
                    onActivityChanged: (v) => _activityLevel = v,
                  ),
                  _StorageModeSlide(
                    onNext: _nextPage,
                    onModeChanged: (v) => _storageMode = v,
                  ),
                  _CycleBaselineSlide(
                    onNext: _completeOnboarding,
                    onEmailChanged: (v) => _email = v,
                    onPasswordChanged: (v) => _password = v,
                    onCycleLengthChanged: (v) => _cycleLength = v,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SLIDE 1: CONSENT ---
class _ConsentSlide extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onLogin;
  const _ConsentSlide({required this.onNext, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: AppColors.primaryMuted),
          AppSpacing.verticalMedium,
          const Text("Your Privacy Matters", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          AppSpacing.verticalSmall,
          const Text("We encrypt your health data. To continue, please agree to our terms.", textAlign: TextAlign.center),
          AppSpacing.verticalLarge,
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, minimumSize: const Size(double.infinity, 50)),
            child: const Text("I Consent", style: TextStyle(color: Colors.white)),
          ),
          AppSpacing.verticalSmall,
          OutlinedButton(
            onPressed: onLogin,
            style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: const BorderSide(color: AppColors.primaryMuted)),
            child: const Text("Login with Email", style: TextStyle(color: AppColors.primaryMuted)),
          ),
        ],
      ),
    );
  }
}

// --- SLIDE 2: BASIC INFO ---
class _BasicInfoSlide extends StatelessWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onNameChanged;
  const _BasicInfoSlide({required this.onNext, required this.onNameChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Tell us your name", style: TextStyle(fontSize: 22, color: AppColors.primaryDark)),
          AppSpacing.verticalMedium,
          TextField(
            onChanged: onNameChanged,
            decoration: const InputDecoration(hintText: "Full Name", border: OutlineInputBorder()),
          ),
          AppSpacing.verticalLarge,
          ElevatedButton(onPressed: onNext, child: const Text("Continue")),
        ],
      ),
    );
  }
}

// --- SLIDE 3: AGE & ACTIVITY ---
class _AgeActivitySlide extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<String> onActivityChanged;
  const _AgeActivitySlide({required this.onNext, required this.onAgeChanged, required this.onActivityChanged});

  @override
  State<_AgeActivitySlide> createState() => _AgeActivitySlideState();
}

class _AgeActivitySlideState extends State<_AgeActivitySlide> {
  String _selectedAge = '';
  String _selectedActivity = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Age Range", style: TextStyle(fontSize: 22, color: AppColors.primaryDark)),
          AppSpacing.verticalSmall,
          Wrap(
            spacing: 8,
            children: ['13-17', '18-25', '26-35', '36-45', '46+'].map((age) {
              final selected = _selectedAge == age;
              return ChoiceChip(
                label: Text(age),
                selected: selected,
                selectedColor: AppColors.lavender,
                onSelected: (_) {
                  setState(() => _selectedAge = age);
                  widget.onAgeChanged(age);
                },
              );
            }).toList(),
          ),
          AppSpacing.verticalMedium,
          const Text("Activity Level", style: TextStyle(fontSize: 22, color: AppColors.primaryDark)),
          AppSpacing.verticalSmall,
          Wrap(
            spacing: 8,
            children: ['Sedentary', 'Light', 'Moderate', 'Active'].map((level) {
              final selected = _selectedActivity == level;
              return ChoiceChip(
                label: Text(level),
                selected: selected,
                selectedColor: AppColors.accentMint,
                onSelected: (_) {
                  setState(() => _selectedActivity = level);
                  widget.onActivityChanged(level);
                },
              );
            }).toList(),
          ),
          AppSpacing.verticalLarge,
          ElevatedButton(onPressed: widget.onNext, child: const Text("Continue")),
        ],
      ),
    );
  }
}

// --- SLIDE 4: STORAGE MODE ---
class _StorageModeSlide extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onModeChanged;
  const _StorageModeSlide({required this.onNext, required this.onModeChanged});

  @override
  State<_StorageModeSlide> createState() => _StorageModeSlideState();
}

class _StorageModeSlideState extends State<_StorageModeSlide> {
  String _mode = 'cloud';

  Widget _modeCard(String mode, String title, String desc, IconData icon) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = mode);
        widget.onModeChanged(mode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.lavender.withValues(alpha: 0.3) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primaryDark : AppColors.lavender, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 28),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.primaryMuted)),
            ])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Data Storage", style: TextStyle(fontSize: 22, color: AppColors.primaryDark)),
          AppSpacing.verticalMedium,
          _modeCard('cloud', 'Cloud Mode', 'Data stored securely on our servers. Full AI features.', Icons.cloud_outlined),
          _modeCard('local', 'Local Mode', 'Data stays on your device only. Maximum privacy.', Icons.phone_android_outlined),
          AppSpacing.verticalLarge,
          ElevatedButton(onPressed: widget.onNext, child: const Text("Continue")),
        ],
      ),
    );
  }
}

// --- SLIDE 5: ACCOUNT & CYCLE BASELINE ---
class _CycleBaselineSlide extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<int> onCycleLengthChanged;
  const _CycleBaselineSlide({required this.onNext, required this.onEmailChanged, required this.onPasswordChanged, required this.onCycleLengthChanged});

  @override
  State<_CycleBaselineSlide> createState() => _CycleBaselineSlideState();
}

class _CycleBaselineSlideState extends State<_CycleBaselineSlide> {
  double _cycleLength = 28;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSpacing.verticalLarge,
            const Text("Create Account", style: TextStyle(fontSize: 22, color: AppColors.primaryDark)),
            AppSpacing.verticalMedium,
            TextField(
              onChanged: widget.onEmailChanged,
              decoration: const InputDecoration(hintText: "Email", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            AppSpacing.verticalSmall,
            TextField(
              onChanged: widget.onPasswordChanged,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password", prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
            ),
            AppSpacing.verticalLarge,
            const Text("Typical Cycle Length", style: TextStyle(fontSize: 18, color: AppColors.primaryDark)),
            AppSpacing.verticalSmall,
            Text("${_cycleLength.round()} days", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryMuted)),
            Slider(
              value: _cycleLength,
              min: 20,
              max: 40,
              divisions: 20,
              activeColor: AppColors.primaryMuted,
              onChanged: (v) {
                setState(() => _cycleLength = v);
                widget.onCycleLengthChanged(v.round());
              },
            ),
            AppSpacing.verticalLarge,
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  setState(() => _isLoading = true);
                  widget.onNext();
                },
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Create Account & Start"),
              ),
            ),
            AppSpacing.verticalMedium,
          ],
        ),
      ),
    );
  }
}
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

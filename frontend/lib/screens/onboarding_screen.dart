import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Functional imports
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

// --- THEME CONSTANTS FOR EXACT VISUAL MATCH ---
const Color _bgWhite = Color(0xFFF7F6F2);
const Color _primaryDark = Color(0xFF45384D);
const Color _primaryMuted = Color(0xFF6E5C77);
const Color _disabledButton = Color(0xFFB1A6B6);
const Color _textGray = Color(0xFF8A8290);
const Color _lightGray = Color(0xFFE4DFE5);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers to capture user input from Step 2
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Data collected from steps 3-5
  String? _selectedAge;
  String? _selectedActivity;
  bool _isLocalStorage = true;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isIrregular = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Hide keyboard
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    if (_isRegistering) return;
    setState(() => _isRegistering = true);

    try {
      final api = ApiService();
      final result = await api.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : 'User',
        ageRange: _selectedAge ?? '18-24',
        activityLevel: _selectedActivity ?? 'Student',
        storageMode: _isLocalStorage ? 'local' : 'cloud',
        cycleVariabilityKnown: _isIrregular,
      );

      await StorageService.saveToken(result['access_token']);
      await StorageService.saveUserId(result['user']['id']);
      await StorageService.saveEmail(_emailController.text.trim());
      await StorageService.saveName(
          _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : 'User');
      await StorageService.saveStorageMode(
          _isLocalStorage ? 'local' : 'cloud');
      await StorageService.saveAgeRange(_selectedAge ?? '18-24');
      await StorageService.saveActivity(_selectedActivity ?? 'Student');
      await StorageService.setOnboardingComplete(true);

      // If user selected a period range, log it as a cycle log
      if (_rangeStart != null) {
        try {
          final bleedingDays = _rangeEnd != null
              ? _rangeEnd!.difference(_rangeStart!).inDays + 1
              : null;
          await api.addCycleLog(
            periodStart: _rangeStart!.toIso8601String().split('T')[0],
            bleedingDays: bleedingDays,
          );
        } catch (_) {
          // Non-critical — don't block navigation
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRegistering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage > 0) _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disables swipe navigation
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: [
                  _Step1Consent(onNext: _nextPage),
                  _Step2BasicInfo(
                    onNext: _nextPage,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  _Step3AgeActivity(
                    onNext: _nextPage,
                    onAgeSelected: (val) => _selectedAge = val,
                    onActivitySelected: (val) => _selectedActivity = val,
                  ),
                  _Step4Storage(
                    onNext: _nextPage,
                    onStorageSelected: (isLocal) => _isLocalStorage = isLocal,
                  ),
                  _Step5CycleBaseline(
                    onFinish: _completeOnboarding,
                    isRegistering: _isRegistering,
                    onRangeChanged: (start, end) {
                      _rangeStart = start;
                      _rangeEnd = end;
                    },
                    onIrregularChanged: (val) => _isIrregular = val,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= (_currentPage - 1);
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? _primaryMuted : _lightGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ==========================================
// SCROLLABLE WRAPPER (FIXED FOR LAYOUT ERRORS)
// ==========================================
class _ScrollableStepWrapper extends StatelessWidget {
  final List<Widget> children;
  final Widget bottomButton;

  const _ScrollableStepWrapper({
    required this.children,
    required this.bottomButton,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          sliver: SliverList(delegate: SliverChildListDelegate(children)),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: true,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 16,
                top: 32,
              ),
              child: bottomButton,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SLIDE 1: CONSENT
// ==========================================
class _Step1Consent extends StatelessWidget {
  final VoidCallback onNext;
  const _Step1Consent({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _ScrollableStepWrapper(
      bottomButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMuted,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "I Consent & Understand",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(
                  color: _primaryMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Icon(Icons.incomplete_circle, size: 40, color: _primaryDark),
        ),
        const SizedBox(height: 50),
        const Text(
          "Actionable Help,\nPrivately Held.",
          style: TextStyle(
            fontSize: 34,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 40),
        _buildFeatureItem(
          icon: Icons.favorite_border,
          title: "Lifestyle Companion",
          description:
              "We don't just track. We provide specific nutrition, movement, and rest protocols.",
        ),
        const SizedBox(height: 24),
        _buildFeatureItem(
          icon: Icons.lock_outline,
          title: "Local-First Trust",
          description:
              "Your health profile and logs never leave your phone unless you choose to back them up.",
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: _primaryDark),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: _textGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SLIDE 2: BASIC INFO
// ==========================================
class _Step2BasicInfo extends StatefulWidget {
  final VoidCallback onNext;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _Step2BasicInfo({
    required this.onNext,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<_Step2BasicInfo> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends State<_Step2BasicInfo> {
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_validateForm);
    widget.emailController.addListener(_validateForm);
    widget.passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        widget.nameController.text.trim().isNotEmpty &&
        widget.emailController.text.trim().isNotEmpty &&
        widget.passwordController.text.isNotEmpty;
    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollableStepWrapper(
      bottomButton: _buildContinueButton(
        widget.onNext,
        disabled: !_isFormValid,
      ),
      children: [
        const Text(
          "Let's personalize your\nexperience",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "This helps us tailor your insights.",
          style: TextStyle(fontSize: 16, color: _textGray),
        ),
        const SizedBox(height: 32),
        const Text(
          "Basic Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 20),
        _buildInputGroup("Name", "Your name", widget.nameController),
        const SizedBox(height: 16),
        _buildInputGroup(
          "Email",
          "your@email.com",
          widget.emailController,
          isEmail: true,
        ),
        const SizedBox(height: 16),
        _buildInputGroup(
          "Password",
          "••••••••",
          widget.passwordController,
          obscure: true,
        ),
      ],
    );
  }

  Widget _buildInputGroup(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textGray,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          style: const TextStyle(color: _primaryDark, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _textGray.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SLIDE 3: AGE & ACTIVITY
// ==========================================
class _Step3AgeActivity extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<String> onAgeSelected;
  final ValueChanged<String> onActivitySelected;
  const _Step3AgeActivity({required this.onNext, required this.onAgeSelected, required this.onActivitySelected});

  @override
  State<_Step3AgeActivity> createState() => _Step3AgeActivityState();
}

class _Step3AgeActivityState extends State<_Step3AgeActivity> {
  String? _selectedAge;
  String? _selectedActivity;

  @override
  Widget build(BuildContext context) {
    bool isComplete = _selectedAge != null && _selectedActivity != null;

    return _ScrollableStepWrapper(
      bottomButton: _buildContinueButton(widget.onNext, disabled: !isComplete),
      children: [
        const Text(
          "Let's personalize your\nexperience",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "This helps us tailor your insights.",
          style: TextStyle(fontSize: 16, color: _textGray),
        ),
        const SizedBox(height: 32),

        const Text(
          "Age Range",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ["Under 18", "18-24", "25-34", "35-44", "45+"].map((age) {
            bool isSelected = _selectedAge == age;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedAge = age);
                widget.onAgeSelected(age);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryMuted : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: _primaryDark, width: 1.5)
                      : null,
                ),
                child: Text(
                  age,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        const Text(
          "Activity Pattern",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActivityCard("Student", Icons.school_outlined),
            _buildActivityCard("Athlete", Icons.emoji_events_outlined),
            _buildActivityCard("Working\nProfessional", Icons.work_outline),
            _buildActivityCard("Mixed Routine", Icons.show_chart),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(String title, IconData icon) {
    bool isSelected = _selectedActivity == title;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedActivity = title);
        widget.onActivitySelected(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _primaryMuted : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected ? Border.all(color: _primaryDark, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : _primaryMuted,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : _textGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SLIDE 4: STORAGE MODE
// ==========================================
class _Step4Storage extends StatefulWidget {
  final VoidCallback onNext;
  final ValueChanged<bool> onStorageSelected;
  const _Step4Storage({required this.onNext, required this.onStorageSelected});

  @override
  State<_Step4Storage> createState() => _Step4StorageState();
}

class _Step4StorageState extends State<_Step4Storage> {
  bool _isLocalSelected = true;

  @override
  Widget build(BuildContext context) {
    return _ScrollableStepWrapper(
      bottomButton: _buildContinueButton(widget.onNext, disabled: false),
      children: [
        const Text(
          "Choose how your data\nis handled",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () {
            setState(() => _isLocalSelected = false);
            widget.onStorageSelected(false);
          },
          child: _buildStorageCard(
            title: "Cloud Mode",
            desc:
                "Secure backup and multi-device access. Your data is synced across your devices.",
            icon: Icons.cloud_queue,
            isSelected: !_isLocalSelected,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() => _isLocalSelected = true);
            widget.onStorageSelected(true);
          },
          child: _buildStorageCard(
            title: "Local Mode",
            desc:
                "Data stays only on this device. Maximum privacy, but no backup if you lose your phone.",
            icon: Icons.gpp_good_outlined,
            isSelected: _isLocalSelected,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageCard({
    required String title,
    required String desc,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? _primaryMuted : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : _bgWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : _primaryDark,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : _primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isSelected ? Colors.white.withOpacity(0.9) : _textGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SLIDE 5: CYCLE BASELINE
// ==========================================
class _Step5CycleBaseline extends StatefulWidget {
  final VoidCallback onFinish;
  final bool isRegistering;
  final Function(DateTime?, DateTime?) onRangeChanged;
  final ValueChanged<bool> onIrregularChanged;
  const _Step5CycleBaseline({required this.onFinish, required this.isRegistering, required this.onRangeChanged, required this.onIrregularChanged});

  @override
  State<_Step5CycleBaseline> createState() => _Step5CycleBaselineState();
}

class _Step5CycleBaselineState extends State<_Step5CycleBaseline> {
  bool isIrregular = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return _ScrollableStepWrapper(
      bottomButton: ElevatedButton(
        onPressed: (_rangeStart == null || widget.isRegistering) ? null : widget.onFinish,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryMuted,
          disabledBackgroundColor: _disabledButton,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: widget.isRegistering
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                "Finish Setup",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      children: [
        const Text(
          "Set Your Cycle\nBaseline",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _primaryDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Initial calibration for personalized insights.",
          style: TextStyle(fontSize: 16, color: _textGray),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Irregular Cycles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "My cycles vary significantly in length",
                      style: TextStyle(
                        fontSize: 13,
                        color: _textGray.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isIrregular,
                onChanged: (val) {
                  setState(() => isIrregular = val);
                  widget.onIrregularChanged(val);
                },
                activeColor: _primaryMuted,
                inactiveTrackColor: _lightGray,
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "LAST PERIOD\nRANGE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: _primaryDark,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(
                    () => _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      1,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: _textGray,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _primaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(
                    () => _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                      1,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: _textGray,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            headerVisible: false,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
              });
              widget.onRangeChanged(start, end);
            },
            onPageChanged: (focusedDay) =>
                setState(() => _focusedDay = focusedDay),
            daysOfWeekHeight: 40,
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) =>
                  DateFormat.E(locale).format(date)[0],
              weekdayStyle: const TextStyle(
                color: _lightGray,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              weekendStyle: const TextStyle(
                color: _lightGray,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(
                color: _primaryDark,
                fontSize: 15,
              ),
              weekendTextStyle: const TextStyle(
                color: _primaryDark,
                fontSize: 15,
              ),
              outsideDaysVisible: false,
              rangeStartDecoration: const BoxDecoration(
                color: _primaryMuted,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: _primaryMuted,
                shape: BoxShape.circle,
              ),
              rangeHighlightColor: _primaryMuted.withOpacity(0.15),
              withinRangeTextStyle: const TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.w600,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: _primaryMuted, width: 2),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "START: ${_rangeStart != null ? DateFormat('MMM d').format(_rangeStart!).toUpperCase() : '---'}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _textGray,
              ),
            ),
            Text(
              "END: ${_rangeEnd != null ? DateFormat('MMM d').format(_rangeEnd!).toUpperCase() : '---'}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: _textGray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 13, color: _textGray, height: 1.4),
              children: [
                TextSpan(
                  text: "Tip: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryDark,
                  ),
                ),
                TextSpan(
                  text:
                      "Selecting your last period range helps us calculate your current cycle day and phase more accurately.",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SHARED WIDGETS
// ==========================================
Widget _buildContinueButton(VoidCallback onPressed, {bool disabled = false}) {
  return ElevatedButton(
    onPressed: disabled ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryMuted,
      disabledBackgroundColor: _disabledButton,
      minimumSize: const Size(double.infinity, 60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
    ),
    child: const Text(
      "Continue",
      style: TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

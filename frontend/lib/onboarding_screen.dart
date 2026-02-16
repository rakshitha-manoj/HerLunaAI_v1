import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'main_layout.dart'; // Ensure this exists for the final transition
import 'services/api_service.dart'; // Ensure this exists for the API call

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  // NEW PROFILE STATES
  // UNIT TOGGLES
  bool _isSigningIn = false; // New variable to track which view to show
  bool _isMetricHeight = true; // true = CM, false = FT/IN
  bool _isMetricWeight = true; // true = KG, false = LBS

  // Extra controller for Feet/Inches split
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String? _selectedAgeRange;
  // Selection States
  String? _selectedCondition;
  final List<String> _selectedGoals = [];

  // Calendar Range States
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isIrregular = false;

  bool _isFuture(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return day.isAfter(today);
  }

  void _nextPage() async {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Final step → Call Backend

      try {
        double? height;
        double? weight;

        // Height conversion
        if (_isMetricHeight) {
          height = double.tryParse(_heightController.text);
        } else {
          final ft = double.tryParse(_feetController.text) ?? 0;
          final inch = double.tryParse(_inchesController.text) ?? 0;
          height = ((ft * 12) + inch) * 2.54; // convert to cm
        }

        // Weight (still simple for now)
        if (_weightController.text.isNotEmpty) {
          weight = double.tryParse(_weightController.text);
        }

        final result = await ApiService.createProfile(
          email: _emailController.text.trim(),
          name: _nameController.text.trim(),
          ageRange: _selectedAgeRange!,
          condition: _mapConditionToBackend(_selectedCondition!),
          goals: _mapGoalsToBackend(),
          height: height,
          weight: weight,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', result['user_id']);
        final userId = result['user_id'];

        // Create initial cycle logs first
        if (_rangeStart != null && _rangeEnd != null) {
          DateTime current = _rangeStart!;

          while (!current.isAfter(_rangeEnd!)) {
            await ApiService.createLog(
              userId: userId,
              logDate: current,
              isPeriodActive: true,
              flowEncoded: null,
              selectedSymptoms: [],
              extraSymptoms: "",
              note: "",
            );

            current = current.add(const Duration(days: 1));
          }
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
      } catch (e) {
        debugPrint("Profile creation failed: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
      }
    }
  }

  String _mapConditionToBackend(String uiValue) {
    switch (uiValue) {
      case "PCOS":
        return "pcos";
      case "Endometriosis":
        return "endometriosis";
      case "PMDD":
        return "pmdd";
      case "Perimenopause":
        return "perimenopause";
      default:
        return "regular";
    }
  }

  List<String> _mapGoalsToBackend() {
    return _selectedGoals.map((goal) {
      switch (goal) {
        case "Manage Fatigue":
          return "manage_fatigue";
        case "Reduce Inflammation":
          return "reduce_inflammation";
        case "Stabilize Mood":
          return "stabilize_mood";
        case "Improve Fertility":
          return "improve_fertility";
        case "Regularize Cycle":
          return "regularize_cycle";
        default:
          return goal.toLowerCase().replaceAll(" ", "_");
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.backgroundBeige,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTopProgressBar(),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) =>
                            setState(() => _currentStep = index),
                        // Look for your PageView children and change the first line:
                        children: [
                          _isSigningIn
                              ? _stepWrapper(_buildSignInStep())
                              : _stepWrapper(_buildConsentStep()),
                          _stepWrapper(_buildPersonalProfileStep()),
                          _stepWrapper(_buildHealthProfileStep()),
                          _stepWrapper(_buildGoalsStep()),
                          _stepWrapper(_buildCalendarStep()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper to make every step scrollable to prevent overflow
  Widget _stepWrapper(Widget child) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: child,
      ),
    );
  }

  Widget _buildTopProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? HerLunaTheme.primaryPlum
                    : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- STEP 1: CONSENT ---
  Widget _buildConsentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Image.asset('assets/logo.png', width: 80),
        const SizedBox(height: 40),
        Text(
          "Actionable Help,\nPrivately Held.",
          style: GoogleFonts.quicksand(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 40),
        _infoRow(
          LucideIcons.heart,
          "Lifestyle Companion",
          "We don't just track. We provide specific nutrition, movement, and rest protocols.",
        ),
        const SizedBox(height: 30),
        _infoRow(
          LucideIcons.lock,
          "Local-First Trust",
          "Your health profile and logs never leave your phone unless you choose to back them up.",
        ),
        const SizedBox(height: 60),

        // Primary "Get Started" Button
        _primaryButton(
          "I Consent & Understand",
          _nextPage,
          icon: Icons.arrow_forward,
        ),

        const SizedBox(height: 16),

        // NEW: Secondary "Sign In" Button
        SizedBox(
          width: double.infinity,
          height: 65,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black12),
              shape: const StadiumBorder(),
            ),
            onPressed: () => setState(() => _isSigningIn = true),
            child: Text(
              "SIGN IN WITH EMAIL",
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: HerLunaTheme.primaryPlum,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSignInStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () => setState(() => _isSigningIn = false),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text("BACK"),
          style: TextButton.styleFrom(foregroundColor: Colors.black45),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HerLunaTheme.primaryPlum.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(LucideIcons.mail, color: HerLunaTheme.primaryPlum),
        ),
        const SizedBox(height: 32),
        Text(
          "Welcome back.",
          style: GoogleFonts.quicksand(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        const Text(
          "Sign in to restore your patterns.",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
        ),
        const SizedBox(height: 40),
        _inputLabel("EMAIL ADDRESS"),
        _customTextField(_emailController, "hello@example.com", isEmail: true),
        const SizedBox(height: 40),
        _primaryButton(
          "Continue with Email",
          _emailController.text.contains('@')
              ? () async {
                  try {
                    final result = await ApiService.loginWithEmail(
                      _emailController.text.trim(),
                    );

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString("user_id", result["user_id"]);

                    if (!mounted) return;

                    if (result["is_new"] == true) {
                      setState(() {
                        _isSigningIn = false;
                      });

                      _pageController.animateToPage(
                        1, // move to Personal Profile step
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Login failed")),
                    );
                  }
                }
              : null,
          icon: Icons.arrow_forward,
        ),

        const SizedBox(height: 24),
        const Center(
          child: Text(
            "We'll send a secure magic link to your inbox.",
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalProfileStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          "Tell us about yourself",
          style: GoogleFonts.quicksand(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        const SizedBox(height: 40),

        // Name Field
        const Text(
          "FIRST NAME",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
        _customTextField(_nameController, "Your name"),
        const SizedBox(height: 30),

        // ADD THIS BLOCK HERE
        const Text(
          "EMAIL ADDRESS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
        _customTextField(_emailController, "hello@example.com", isEmail: true),

        const SizedBox(height: 30),

        // Age Range Selector
        const Text(
          "AGE RANGE",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ["<18", "18-25", "26-35", "36-45", "45+"].map((r) {
            bool isSel = _selectedAgeRange == r;
            return InkWell(
              onTap: () => setState(() => _selectedAgeRange = r),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSel ? HerLunaTheme.primaryPlum : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSel ? Colors.transparent : Colors.black12,
                  ),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSel ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        // Height and Weight
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEIGHT SECTION ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _inputLabel("HEIGHT"),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isMetricHeight = !_isMetricHeight),
                        child: Text(
                          _isMetricHeight ? "CM" : "FT",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: HerLunaTheme.primaryPlum,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _isMetricHeight
                      ? _customTextField(_heightController, "Value")
                      : Row(
                          children: [
                            Expanded(
                              child: _customTextField(_feetController, "FT"),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _customTextField(_inchesController, "IN"),
                            ),
                          ],
                        ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // --- WEIGHT SECTION ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _inputLabel("WEIGHT"),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isMetricWeight = !_isMetricWeight),
                        child: Text(
                          _isMetricWeight ? "KG" : "LBS",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: HerLunaTheme.primaryPlum,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _customTextField(
                    _weightController,
                    _isMetricWeight ? "Value" : "Value",
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 60),
        _primaryButton(
          "Continue Profile",
          (_nameController.text.isNotEmpty &&
                  _emailController.text.contains('@') && // Added email check
                  _selectedAgeRange != null)
              ? _nextPage
              : null,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // Helper for the TextFields
  // Small helper for consistent labels
  Widget _inputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 1.2,
      ),
    );
  }

  // Updated text field to support the "Value" hints and unit suffixes
  Widget _customTextField(
    TextEditingController controller,
    String hint, {
    bool isEmail = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        // If isEmail is true, show email keyboard; otherwise show standard text keyboard
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- STEP 2: HEALTH PROFILE ---
  Widget _buildHealthProfileStep() {
    final options = {
      "Regular / No Condition": "Standard pattern tracking",
      "PCOS": "Metabolic & cycle regulation",
      "Endometriosis": "Inflammation & pain focus",
      "PMDD": "Severe luteal mood shifts",
      "Perimenopause": "Transition & symptom relief",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          "Your Health Profile",
          style: GoogleFonts.quicksand(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        Text(
          "What condition are we managing?",
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 30),
        ...options.entries.map((e) => _conditionTile(e.key, e.value)),
        const SizedBox(height: 40),
        _primaryButton(
          "Continue",
          _selectedCondition != null ? _nextPage : null,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // --- STEP 3: GOALS ---
  Widget _buildGoalsStep() {
    final goals = [
      "Manage Fatigue",
      "Reduce Inflammation",
      "Stabilize Mood",
      "Improve Fertility",
      "Regularize Cycle",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          "Define Your Goals",
          style: GoogleFonts.quicksand(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        const Text(
          "What can HerLuna help you with most?",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 32),
        Column(children: goals.map((g) => _goalTile(g)).toList()),
        const SizedBox(height: 40),
        _primaryButton(
          "Set Goals",
          _selectedGoals.isNotEmpty ? _nextPage : null,
          icon: LucideIcons.target,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _goalTile(String goal) {
    bool isSel = _selectedGoals.contains(goal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSel) {
              _selectedGoals.remove(goal);
            } else {
              _selectedGoals.add(goal);
            }
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: isSel ? HerLunaTheme.primaryPlum : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSel
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Text(
            goal,
            style: GoogleFonts.quicksand(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isSel ? Colors.white : HerLunaTheme.primaryPlum,
            ),
          ),
        ),
      ),
    );
  }

  // --- STEP 4: CALENDAR ---
  Widget _buildCalendarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          "Initial Setup",
          style: GoogleFonts.quicksand(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        const Text(
          "Select the start and end of your last cycle.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.now(),
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.enforced,
            enabledDayPredicate: (day) => !_isFuture(day),
            onRangeSelected: (start, end, focusedDay) {
              if (start != null && _isFuture(start)) return;

              setState(() {
                _rangeStart = start;
                _rangeEnd = end;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.quicksand(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: HerLunaTheme.primaryPlum,
              ),
            ),
            calendarStyle: CalendarStyle(
              rangeStartDecoration: const BoxDecoration(
                color: HerLunaTheme.primaryPlum,
                shape: BoxShape.circle,
              ),
              rangeEndDecoration: const BoxDecoration(
                color: HerLunaTheme.primaryPlum,
                shape: BoxShape.circle,
              ),
              rangeHighlightColor: HerLunaTheme.primaryPlum.withOpacity(0.12),
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: HerLunaTheme.primaryPlum, width: 2),
              ),
              todayTextStyle: const TextStyle(
                color: HerLunaTheme.primaryPlum,
                fontWeight: FontWeight.bold,
              ),
              disabledTextStyle: const TextStyle(color: Colors.black12),
            ),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My periods are irregular",
                style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: HerLunaTheme.primaryPlum,
                ),
              ),
              Switch(
                value: _isIrregular,
                activeColor: HerLunaTheme.primaryPlum,
                onChanged: (bool value) => setState(() => _isIrregular = value),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
        _primaryButton("Enter HerLuna", _rangeStart != null ? _nextPage : null),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _infoRow(IconData icon, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: HerLunaTheme.primaryPlum, size: 22),
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _conditionTile(String title, String sub) {
    bool isSel = _selectedCondition == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCondition = title),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isSel ? HerLunaTheme.primaryPlum : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSel
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.white : HerLunaTheme.primaryPlum,
                ),
              ),
              Text(
                sub,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: isSel ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalChip(String goal) {
    bool isSel = _selectedGoals.contains(goal);

    return ChoiceChip(
      label: Text(goal),
      selected: isSel,
      onSelected: (val) => setState(
        () => val ? _selectedGoals.add(goal) : _selectedGoals.remove(goal),
      ),
      selectedColor: HerLunaTheme.primaryPlum,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSel ? Colors.white : HerLunaTheme.primaryPlum,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: StadiumBorder(
        side: BorderSide(color: isSel ? Colors.transparent : Colors.black12),
      ),
      showCheckmark: false,
    );
  }

  Widget _primaryButton(String text, VoidCallback? onTab, {IconData? icon}) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E738E),
          disabledBackgroundColor: const Color(0xFF8E738E).withOpacity(0.4),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        onPressed: onTab,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

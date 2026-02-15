import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart'; // REQUIRED
import 'theme.dart';
import 'main.dart'; // Required to access HerLunaApp.of(context)

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isSyncEnabled = false;
  String _selectedCondition = "Regular";
  List<String> _activeGoals = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences(); // FETCH DATA ON LOAD
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCondition = prefs.getString('user_condition') ?? "Regular";
      _activeGoals = prefs.getStringList('user_goals') ?? [];
      _isSyncEnabled = prefs.getBool('is_sync_enabled') ?? false;
    });
  }

  // NEW: Save condition change to DB
  Future<void> _updateCondition(String cond) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_condition', cond);
    setState(() => _selectedCondition = cond);
  }

  // NEW: Save goal toggles to DB
  Future<void> _toggleGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_activeGoals.contains(goal)) {
        _activeGoals.remove(goal);
      } else {
        _activeGoals.add(goal);
      }
    });
    await prefs.setStringList('user_goals', _activeGoals);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are currently in dark mode to sync the switch state
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildAppearanceCard(context, isDark),
                  const SizedBox(height: 16),
                  _buildHealthProfileCard(context),
                  const SizedBox(height: 16),
                  _buildSyncCard(context),
                  const SizedBox(height: 16),
                  _buildActionList(context),
                  const SizedBox(height: 24),
                  _buildEthosCard(context),
                  const SizedBox(height: 24),
                  _buildFooter(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: GoogleFonts.quicksand(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        Text(
          "Manage your profile and data",
          style: GoogleFonts.quicksand(
            fontSize: 16,
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              color: isDark ? Colors.white : HerLunaTheme.primaryPlum,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Appearance",
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  isDark ? "DARK MODE" : "LIGHT MODE",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.black26,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          // Inside _buildAppearanceCard in settings_view.dart
          Switch(
            // Check the ACTUAL theme of the app, not a local variable
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool newValue) {
              // This calls the global toggle we built in main.dart
              HerLunaApp.of(context).toggleTheme(newValue);
            },
            activeColor: HerLunaTheme.primaryPlum,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProfileCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.activity,
                color: Colors.tealAccent,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Health Profile",
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "Drives your LifeGuide intelligence",
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "MANAGED CONDITION",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: HerLunaTheme.accentPlum,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  "Regular",
                  "PCOS",
                  "Endometriosis",
                  "PMDD",
                  "Perimenopause",
                ].map((cond) {
                  bool isSelected = _selectedCondition == cond;
                  return GestureDetector(
                    onTap: () =>
                        _updateCondition(cond), // CHANGED: Calls save logic
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HerLunaTheme.primaryPlum
                            : (isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : HerLunaTheme.backgroundBeige.withOpacity(
                                      0.5,
                                    )),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        cond,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black45),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            "ACTIVE GOALS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: HerLunaTheme.accentPlum,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // CHANGED: Dynamically map from all possible goals
              ...[
                "Manage Fatigue",
                "Stabilize Mood",
                "Regularize Cycle",
                "Reduce Inflammation",
              ].map((goal) {
                return _goalChip(context, goal);
              }),
              _addGoalChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalChip(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isSelected = _activeGoals.contains(label); // CHECK IF ACTIVE

    return GestureDetector(
      onTap: () => _toggleGoal(label), // TOGGLE ON TAP
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? HerLunaTheme.primaryPlum.withOpacity(0.2)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : HerLunaTheme.backgroundBeige),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: HerLunaTheme.primaryPlum)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? HerLunaTheme.primaryPlum
                : (isDark ? Colors.white60 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _addGoalChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.tealAccent.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "+ Add Goal",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.cloud,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cloud Backup & Sync",
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      "Encrypted off-device storage",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isSyncEnabled,
                onChanged: (v) => setState(() => _isSyncEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : HerLunaTheme.backgroundBeige.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _syncRow(context, "STATUS", "Local Storage Only"),
                const SizedBox(height: 12),
                _syncRow(context, "LAST SYNCED", "Not Synced"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                LucideIcons.lock,
                size: 12,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Data is end-to-end encrypted. HerLuna cannot read your personal logs.",
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _actionRow(
            context,
            LucideIcons.download,
            "Export Data (JSON)",
            false,
          ),
          const Divider(indent: 60, height: 1, color: Colors.black12),
          _actionRow(
            context,
            LucideIcons.fileText,
            "Privacy & Ethics Policy",
            false,
          ),
          const Divider(indent: 60, height: 1, color: Colors.black12),
          _actionRow(context, LucideIcons.heart, "Support HerLuna", false),
          const Divider(indent: 60, height: 1, color: Colors.black12),
          _actionRow(context, LucideIcons.trash2, "Reset All Data", true),
        ],
      ),
    );
  }

  Widget _actionRow(
    BuildContext context,
    IconData icon,
    String title,
    bool isDestructive,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.05)
              : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : HerLunaTheme.backgroundBeige),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDestructive
              ? Colors.redAccent
              : (isDark ? Colors.white70 : HerLunaTheme.primaryPlum),
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? Colors.redAccent
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 18,
        color: Colors.black12,
      ),
    );
  }

  Widget _buildEthosCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.02)
            : HerLunaTheme.backgroundBeige.withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "OUR ETHOS",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: HerLunaTheme.primaryPlum,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "We believe in your right to pattern understanding without surveillance. Your device is the ultimate source of truth.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  size: 16,
                  color: Colors.teal,
                ),
                const SizedBox(width: 8),
                Text(
                  "ZERO-KNOWLEDGE ARCHITECTURE",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            "HERLUNA V1.2.0",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.black26,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Pattern Awareness · LifeGuide Engine",
            style: TextStyle(fontSize: 11, color: Colors.black26),
          ),
        ],
      ),
    );
  }
}

class _syncRow extends StatelessWidget {
  final BuildContext context;
  final String label, value;
  const _syncRow(this.context, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

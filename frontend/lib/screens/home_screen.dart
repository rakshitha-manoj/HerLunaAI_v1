import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/prediction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // ── Live data ──
  String _userName = 'Alex';
  String _phase = 'Follicular';
  int _dayInCycle = 8;
  int _cycleLength = 28;
  String _energyInsight = 'Your patterns suggest a peak at 2 PM. Schedule deep work then.';
  String _sleepInsight = 'Rest was 15% better than last Tuesday. Keep the room cool.';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await StorageService.getUserId();
      final email = await StorageService.getEmail();
      final storageMode = await StorageService.getStorageMode();
      if (email != null) _userName = email.split('@').first;

      if (userId != null) {
        final p = await ApiService().predict(userId: userId, storageMode: storageMode);
        if (mounted) {
          setState(() {
            _phase = p.dominantPhase;
            _dayInCycle = p.physiologicalState.estimatedDayInCycle;
            if (_dayInCycle == 0) _dayInCycle = 8;
            _energyInsight = _energyText(p);
            _sleepInsight = _sleepText(p);
          });
        }
      }
    } catch (_) {}
  }

  String _energyText(PredictionModel p) {
    if (p.fatigueProbability > 0.7) return 'High fatigue detected. Consider light tasks and rest today.';
    if (p.dominantPhase == 'Follicular') return 'Rising energy — great window for demanding tasks.';
    if (p.dominantPhase == 'Ovulatory') return 'Peak energy expected. Schedule deep work now.';
    return 'Your patterns suggest a peak at 2 PM. Schedule deep work then.';
  }

  String _sleepText(PredictionModel p) {
    if (p.stressProbability > 0.7) return 'Elevated stress. Try breathing exercises or a walk.';
    if (p.dominantPhase == 'Luteal') return 'Higher sensitivity is common. Consider a lighter schedule.';
    return 'Rest was 15% better than last Tuesday. Keep the room cool.';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/inference_response.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.inferenceResult == null) {
        provider.runInference();
      }
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "HerLuna AI",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primaryDark),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.lavender,
              child: Icon(Icons.person, size: 20, color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Text(
              "Good morning, $_userName",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
            const Text(
              "Here is your pattern overview for today.",
              style: TextStyle(color: AppColors.primaryMuted),
            ),
            
            AppSpacing.verticalMedium,

            // Main Status Card (Using Mint Accent)
            _buildMainStatusCard(),

            AppSpacing.verticalMedium,

            // Insight Section
            const Text(
              "AI Insights",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            AppSpacing.verticalSmall,
            
            _buildInsightCard(
              title: "Energy Levels",
              description: _energyInsight,
              icon: Icons.bolt,
              color: AppColors.lavender,
            ),
            
            AppSpacing.verticalSmall,

            _buildInsightCard(
              title: "Sleep Quality",
              description: _sleepInsight,
              icon: Icons.nightlight_round,
              color: AppColors.accentMint,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMainStatusCard() {
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final result = provider.inferenceResult;
            final name = provider.currentUser?.email.split('@').first ?? '';

            return RefreshIndicator(
              color: HerLunaTheme.primary,
              onRefresh: () => provider.runInference(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: HerLunaTheme.horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Top bar with greeting and settings
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_greeting,',
                                style: HerLunaTheme.bodyMedium.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                name.isNotEmpty ? name : 'there',
                                style: HerLunaTheme.heading2,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: HerLunaTheme.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: HerLunaTheme.cardShadow,
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: HerLunaTheme.textSecondary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's your current state.",
                      style: HerLunaTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // ── Hero Card (Phase) ─────────────────────────
                    _buildHeroCard(result),
                    const SizedBox(height: 16),

                    // ── Energy & Stress side-by-side ──────────────
                    Row(
                      children: [
                        Expanded(child: _buildEnergyCard(result)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStressCard(result)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Readiness Card ────────────────────────────
                    _buildReadinessCard(result),
                    const SizedBox(height: 24),

                    // Loading indicator
                    if (provider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: HerLunaTheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(InferenceResponse? result) {
    final phase = _dominantPhase(result);
    final confidence = result?.confidenceScore ?? 0.0;
    final insight = _phaseInsight(phase);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        gradient: HerLunaTheme.heroGradient,
        borderRadius: BorderRadius.circular(HerLunaTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: HerLunaTheme.primary.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Current Phase", style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text("$_phase Phase", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          AppSpacing.verticalSmall,
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.accentMint, size: 16),
              const SizedBox(width: 8),
              Text("Day $_dayInCycle of $_cycleLength", style: const TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required String title, required String description, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, child: Icon(icon, color: AppColors.primaryDark)),
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Current Phase',
                style: HerLunaTheme.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            phase,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Confidence bar
          Row(
            children: [
              Text(
                'Confidence',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: confidence,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(confidence * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyCard(InferenceResponse? result) {
    final fatigue = result?.fatigueProbability ?? 0.5;
    final energy = 1.0 - fatigue;

    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_outlined,
                  color: HerLunaTheme.primary, size: 18),
              const SizedBox(width: 6),
              Text('Energy', style: HerLunaTheme.labelText),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${(energy * 100).round()}%',
            style: HerLunaTheme.heading2.copyWith(
              color: HerLunaTheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            energy > 0.6 ? 'Feeling good' : 'Conserve energy',
            style: HerLunaTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStressCard(InferenceResponse? result) {
    final stress = result?.stressProbability ?? 0.5;

    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined,
                  color: HerLunaTheme.accent, size: 18),
              const SizedBox(width: 6),
              Text('Stress', style: HerLunaTheme.labelText),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            stress < 0.4
                ? 'Low'
                : stress < 0.7
                    ? 'Moderate'
                    : 'High',
            style: HerLunaTheme.heading2.copyWith(
              color: stress > 0.7
                  ? HerLunaTheme.error
                  : HerLunaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(stress * 100).round()}% probability',
            style: HerLunaTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessCard(InferenceResponse? result) {
    final readiness = result?.readinessScore ?? 50.0;

    return HerLunaCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HerLunaTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_outlined,
              color: HerLunaTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.primaryMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.primaryMuted.withOpacity(0.5),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "Trends"),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40, color: AppColors.primaryMuted), label: "Log"),
        BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: "AI"),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
      ],
    );
  }
}
                Text('Readiness Score',
                    style: HerLunaTheme.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  'Overall wellness: ${readiness.round()}/100',
                  style: HerLunaTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '${readiness.round()}',
            style: HerLunaTheme.heading1.copyWith(
              color: HerLunaTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _dominantPhase(InferenceResponse? result) {
    if (result == null) return 'Analyzing...';
    final ps = result.phaseProbability;
    final map = {
      'Menstrual': ps.menstrual,
      'Follicular': ps.follicular,
      'Ovulatory': ps.ovulatory,
      'Luteal': ps.luteal,
    };
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _phaseInsight(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Rest and recovery may feel more important today.';
      case 'Follicular':
        return 'Energy is typically rising — a good time for new plans.';
      case 'Ovulatory':
        return 'Peak energy and social connection likely.';
      case 'Luteal':
        return 'Energy may feel slightly lower today.';
      default:
        return 'Gathering data for personalized insights.';
    }
  }
}

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
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
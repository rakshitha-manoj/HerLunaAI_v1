import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/spacing.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/prediction_model.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Defaults match user's original UI
  String _summaryTitle = 'High Consistency';
  String _summaryBody = "You've logged for 6 days straight. Your AI model is now 85% accurate.";
  String _energyInsight = 'Your energy crashes 2 hours earlier on days you log caffeine after 1 PM.';
  String _sleepInsight = 'Consistent 7+ hours of sleep reduces logged anxiety by 40% in your Luteal phase.';
  String _recommendation = 'Try increasing magnesium intake this week to support your rising progesterone levels.';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await StorageService.getUserId();
      final storageMode = await StorageService.getStorageMode();
      final api = ApiService();
      if (userId != null) {
        final prediction = await api.predict(userId: userId, storageMode: storageMode);
        final analytics = await api.getAnalytics();
        if (mounted) {
          final streak = analytics['log_streak'] ?? 6;
          final accuracy = ((prediction.confidenceScore) * 100).round();
          setState(() {
            _summaryTitle = streak > 5 ? 'High Consistency' : streak > 2 ? 'Building Momentum' : 'Getting Started';
            _summaryBody = "You've logged for $streak days straight. Your AI model is now $accuracy% accurate.";
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "AI Insights",
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Weekly Summary Card
            _buildSummaryCard(),

            AppSpacing.verticalMedium,

            const Text(
              "Detected Patterns",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            AppSpacing.verticalSmall,

            // 2. Pattern List
            _buildPatternItem(
              title: "Energy & Caffeine",
              insight: _energyInsight,
              icon: Icons.coffee_outlined,
              color: AppColors.lavender,
            ),
            AppSpacing.verticalSmall,
            _buildPatternItem(
              title: "Sleep & Mood",
              insight: _sleepInsight,
              icon: Icons.auto_awesome,
              color: AppColors.accentMint,
            ),

            AppSpacing.verticalLarge,

            // 3. Simple Bar Chart Representation (Placeholder)
            const Text(
              "Mood Correlation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            AppSpacing.verticalMedium,
            _buildMiniChart(),
            
            AppSpacing.verticalLarge,

            // 4. Recommendation Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryMuted.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Personalized Recommendation",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recommendation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primaryMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryMuted],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("This Week", style: TextStyle(color: Colors.white70)),
          Text(_summaryTitle, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            _summaryBody,
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternItem({required String title, required String insight, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                const SizedBox(height: 4),
                Text(insight, style: const TextStyle(fontSize: 14, color: AppColors.primaryMuted, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _chartBar(40, "Mon"),
        _chartBar(70, "Tue"),
        _chartBar(90, "Wed"),
        _chartBar(50, "Thu"),
        _chartBar(80, "Fri"),
        _chartBar(60, "Sat"),
        _chartBar(30, "Sun"),
      ],
    );
  }

  Widget _chartBar(double height, String label) {
    return Column(
      children: [
        Container(
          height: height,
          width: 12,
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.primaryMuted)),
      ],
    );
  }
}
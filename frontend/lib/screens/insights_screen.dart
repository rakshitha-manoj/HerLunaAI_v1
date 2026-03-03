import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final result = provider.inferenceResult;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Text('Insights', style: HerLunaTheme.heading2),
                ),
                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: HerLunaTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: HerLunaTheme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: HerLunaTheme.cardShadow,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: HerLunaTheme.primary,
                    unselectedLabelColor: HerLunaTheme.textSecondary,
                    labelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Cycle'),
                      Tab(text: 'Energy'),
                      Tab(text: 'Stress'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCycleTab(result),
                      _buildEnergyTab(result),
                      _buildStressTab(result),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCycleTab(dynamic result) {
    final ps = result?.physiologicalState?.phaseProbability;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _insightCard(
            'Cycle Stability',
            'Based on your logged cycles',
            Icons.timeline_outlined,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _metricRow(
                    'Variability',
                    result?.meta?.baselineMetrics?.cycleVariabilityIndex != null
                        ? '${(result.meta.baselineMetrics.cycleVariabilityIndex * 100).toStringAsFixed(1)}%'
                        : 'Needs data'),
                _metricRow(
                    'Avg Length',
                    result?.meta?.baselineMetrics?.meanCycleLength != null
                        ? '${result.meta.baselineMetrics.meanCycleLength.toStringAsFixed(1)} days'
                        : 'Needs data'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _insightCard(
            'Phase Distribution',
            'Current probability breakdown',
            Icons.pie_chart_outline,
            child: ps != null
                ? Column(
                    children: [
                      const SizedBox(height: 12),
                      _phaseBar('Menstrual', ps.menstrual),
                      _phaseBar('Follicular', ps.follicular),
                      _phaseBar('Ovulatory', ps.ovulatory),
                      _phaseBar('Luteal', ps.luteal),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('Run inference for phase data',
                        style: HerLunaTheme.bodySmall),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEnergyTab(dynamic result) {
    final fatigue = result?.performanceState?.fatigueProbability ?? 0.5;
    final readiness = result?.performanceState?.readinessScore ?? 50.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _insightCard(
            'Fatigue Probability',
            'Estimated from behavioral patterns',
            Icons.battery_3_bar_outlined,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _progressIndicator(fatigue, 'fatigue'),
                const SizedBox(height: 8),
                Text(
                  '${(fatigue * 100).round()}% fatigue probability',
                  style: HerLunaTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _insightCard(
            'Readiness',
            'Overall wellness readiness score',
            Icons.fitness_center_outlined,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _metricRow('Score', '${readiness.round()}/100'),
                _metricRow(
                    'Level',
                    readiness > 70
                        ? 'Good'
                        : readiness > 40
                            ? 'Moderate'
                            : 'Low'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _insightCard(
            'Explanation',
            'Key contributing factors',
            Icons.psychology_outlined,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (result?.meta?.topFeatures
                            ?.map<Widget>((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 5,
                                          color: HerLunaTheme.accent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(f.toString(),
                                            style: HerLunaTheme.bodyMedium),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList() as List<Widget>?) ??
                    [
                      const Text('Run inference for insights',
                          style: HerLunaTheme.bodySmall),
                    ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStressTab(dynamic result) {
    final stress = result?.riskState?.stressProbability ?? 0.5;
    final anomaly = result?.riskState?.anomalyFlag ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _insightCard(
            'Burnout Risk',
            'Based on screen time and schedule',
            Icons.local_fire_department_outlined,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _progressIndicator(stress, 'stress'),
                const SizedBox(height: 8),
                Text(
                  stress < 0.4
                      ? 'Low risk'
                      : stress < 0.7
                          ? 'Moderate risk'
                          : 'High risk — consider reducing load',
                  style: HerLunaTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _insightCard(
            'Behavioral Deviation',
            'Compared to your personal baseline',
            Icons.show_chart,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _metricRow(
                    'Deviation Score',
                    result?.meta?.baselineMetrics
                                ?.behavioralDeviationScore !=
                            null
                        ? result.meta.baselineMetrics.behavioralDeviationScore
                            .toStringAsFixed(2)
                        : 'N/A'),
                _metricRow('Anomaly Detected', anomaly ? 'Yes' : 'No'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _insightCard(
            'Stress Probability',
            'Multi-agent composite score',
            Icons.spa_outlined,
            child: Column(
              children: [
                const SizedBox(height: 12),
                _metricRow('Probability', '${(stress * 100).round()}%'),
                _metricRow(
                    'Trend',
                    (result?.meta?.trendFlags?.length ?? 0) > 0
                        ? result.meta.trendFlags.first.toString()
                        : 'Stable'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _insightCard(String title, String subtitle, IconData icon,
      {Widget? child}) {
    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: HerLunaTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            HerLunaTheme.heading3.copyWith(fontSize: 15)),
                    Text(subtitle, style: HerLunaTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: HerLunaTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: HerLunaTheme.bodyLarge
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _phaseBar(String name, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name, style: HerLunaTheme.bodySmall),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: HerLunaTheme.accentLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(HerLunaTheme.primary),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(value * 100).round()}%',
            style: HerLunaTheme.bodySmall
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _progressIndicator(double value, String type) {
    final color = type == 'stress'
        ? (value > 0.7
            ? HerLunaTheme.error
            : value > 0.4
                ? const Color(0xFFD4A537)
                : HerLunaTheme.success)
        : (value > 0.7
            ? HerLunaTheme.error
            : value > 0.4
                ? const Color(0xFFD4A537)
                : HerLunaTheme.success);

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              backgroundColor: HerLunaTheme.accentLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: HerLunaTheme.heading3
                .copyWith(fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}

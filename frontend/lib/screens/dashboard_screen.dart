import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/phase_probability_chart.dart';
import '../widgets/confidence_indicator.dart';
import 'cycle_screen.dart';
import 'performance_screen.dart';
import 'stress_screen.dart';
import 'travel_screen.dart';
import 'guidance_screen.dart';
import 'care_screen.dart';
import 'mode_selection_screen.dart';

/// Main dashboard showing key metrics, phase probabilities,
/// and navigation to detailed screens.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.fetchCycleLogs();
    await provider.fetchBehavioralData();
    await provider.fetchTravelData();
    await provider.runInference();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HerLuna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await provider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ModeSelectionScreen()),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'mode',
                enabled: false,
                child: Text('Mode: ${provider.storageMode.toUpperCase()}'),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: provider.isLoading && result == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Key Metrics ───────────────────────────────────
                    if (result != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Fatigue',
                              value: '${(result.fatigueProbability * 100).toInt()}%',
                              icon: Icons.battery_alert,
                              color: result.fatigueProbability > 0.6
                                  ? Colors.red
                                  : Colors.green,
                              onTap: () => _navigate(const PerformanceScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              title: 'Stress',
                              value: '${(result.stressProbability * 100).toInt()}%',
                              icon: Icons.psychology,
                              color: result.stressProbability > 0.6
                                  ? Colors.red
                                  : Colors.green,
                              onTap: () => _navigate(const StressScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Readiness',
                              value: '${(result.readinessScore * 100).toInt()}%',
                              icon: Icons.flash_on,
                              color: const Color(0xFF8B5CF6),
                              onTap: () => _navigate(const PerformanceScreen()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StatCard(
                              title: 'Phase',
                              value: result.phaseProbability.dominantPhase,
                              icon: Icons.auto_graph,
                              color: const Color(0xFFF59E0B),
                              onTap: () => _navigate(const CycleScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Confidence ────────────────────────────────────
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ConfidenceIndicator(confidence: result.confidenceScore),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Model Confidence',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Based on cycle regularity and available data points.',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Phase Probability Chart ───────────────────────
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: PhaseProbabilityChart(
                            phaseProbability: result.phaseProbability,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Why This Suggestion ───────────────────────────
                      if (result.topFeatures.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Why This Suggestion?',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...result.topFeatures.map((f) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_right, size: 18),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(f)),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // ── Anomaly Alert ──────────────────────────────────
                      if (result.anomalyFlag)
                        Card(
                          color: Colors.amber.withOpacity(0.1),
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber, color: Colors.amber),
                            title: const Text('Anomaly Detected'),
                            subtitle: const Text(
                              'An unusual pattern was detected in your recent data. '
                              'Consider consulting a healthcare professional if this persists.',
                            ),
                          ),
                        ),

                      // ── Disclaimers ────────────────────────────────────
                      const SizedBox(height: 20),
                      ...result.disclaimers.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '⚠ $d',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor),
                            ),
                          )),
                    ],

                    if (provider.error != null && result == null)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.error_outline,
                                size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 12),
                            Text(provider.error!),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadData,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          final screens = [
            null, // dashboard (current)
            const CycleScreen(),
            const PerformanceScreen(),
            const GuidanceScreen(),
            const CareScreen(),
          ];
          if (idx > 0 && idx < screens.length) {
            _navigate(screens[idx]!);
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Cycle'),
          NavigationDestination(icon: Icon(Icons.flash_on), label: 'Performance'),
          NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Guidance'),
          NavigationDestination(icon: Icon(Icons.local_hospital), label: 'Care'),
        ],
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

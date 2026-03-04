import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';

/// Stress screen showing stress/burnout probability and screen time deviation.
class StressScreen extends StatelessWidget {
  const StressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Stress & Wellbeing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result != null) ...[
              // ── Stress Metric ───────────────────────────────────────
              StatCard(
                title: 'Stress Probability',
                value: '${(result.stressProbability * 100).toInt()}%',
                icon: Icons.psychology,
                color: result.stressProbability > 0.6
                    ? Colors.red
                    : result.stressProbability > 0.4
                        ? Colors.orange
                        : const Color(0xFF10B981),
              ),
              const SizedBox(height: 12),

              // ── Burnout Risk Level ──────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Burnout Risk Assessment',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildRiskIndicator(result.stressProbability, theme),
                      const SizedBox(height: 16),
                      // Visual stress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: result.stressProbability,
                          minHeight: 12,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            _getStressColor(result.stressProbability),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Low', style: theme.textTheme.bodySmall),
                          Text('Moderate', style: theme.textTheme.bodySmall),
                          Text('High', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Contributing Factors ────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contributing Factors',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...result.topFeatures.map((f) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_right,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Expanded(child: Text(f)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Recommendations ─────────────────────────────────────
              Card(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Stress Management Tips',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTip('Take short 5-minute breathing breaks', theme),
                      _buildTip('Reduce screen time before bed', theme),
                      _buildTip('Schedule intentional rest periods', theme),
                      _buildTip('Consider gentle exercise or walking', theme),
                    ],
                  ),
                ),
              ),
            ],

            if (result == null)
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.psychology_alt, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No stress data available yet.'),
                    Text('Log some behavioral data first.'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(double stress, ThemeData theme) {
    String level;
    Color color;
    IconData icon;

    if (stress >= 0.7) {
      level = 'HIGH RISK';
      color = Colors.red;
      icon = Icons.error;
    } else if (stress >= 0.4) {
      level = 'MODERATE';
      color = Colors.orange;
      icon = Icons.warning_amber;
    } else {
      level = 'LOW RISK';
      color = const Color(0xFF10B981);
      icon = Icons.check_circle;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          level,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStressColor(double stress) {
    if (stress >= 0.7) return Colors.red;
    if (stress >= 0.4) return Colors.orange;
    return const Color(0xFF10B981);
  }

  Widget _buildTip(String tip, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(tip, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

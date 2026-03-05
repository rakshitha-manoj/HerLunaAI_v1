import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/behavioral_data.dart';
import '../widgets/stat_card.dart';

/// Performance screen showing readiness score and fatigue trends.
/// Allows logging behavioral data (step count, screen time, calendar load).
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  final _stepController = TextEditingController();
  final _screenTimeController = TextEditingController();
  final _calendarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Key Metrics ───────────────────────────────────────────
            if (result != null) ...[
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Readiness',
                      value: '${(result.readinessScore * 100).toInt()}%',
                      icon: Icons.flash_on,
                      color: result.readinessScore > 0.6
                          ? const Color(0xFF10B981)
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      title: 'Fatigue',
                      value: '${(result.fatigueProbability * 100).toInt()}%',
                      icon: Icons.battery_alert,
                      color: result.fatigueProbability > 0.6
                          ? Colors.red
                          : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── Log Behavioral Data ───────────────────────────────────
            Text(
              'Log Today\'s Activity',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _stepController,
                      decoration: InputDecoration(
                        labelText: 'Step Count',
                        prefixIcon: const Icon(Icons.directions_walk),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _screenTimeController,
                      decoration: InputDecoration(
                        labelText: 'Screen Time (hours)',
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _calendarController,
                      decoration: InputDecoration(
                        labelText: 'Calendar Events',
                        prefixIcon: const Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _logData,
                        icon: const Icon(Icons.add),
                        label: const Text('Log Activity'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Recent Activity History ───────────────────────────────
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.behavioralData.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No activity data yet'),
                  subtitle: Text('Log your daily activity above.'),
                ),
              )
            else
              ...provider.behavioralData.take(7).map((d) => Card(
                    child: ListTile(
                      title: Text(
                        '${d.date.day}/${d.date.month}/${d.date.year}',
                      ),
                      subtitle: Text(
                        '${d.stepCount} steps • ${d.screenTime}h screen • ${d.calendarLoad} events',
                      ),
                      leading: Icon(Icons.timeline,
                          color: theme.colorScheme.primary),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _logData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.addBehavioralData(BehavioralData(
      userId: provider.currentUser?.id ?? 0,
      stepCount: int.tryParse(_stepController.text) ?? 0,
      screenTime: double.tryParse(_screenTimeController.text) ?? 0.0,
      calendarLoad: int.tryParse(_calendarController.text) ?? 0,
      date: DateTime.now(),
    ));

    _stepController.clear();
    _screenTimeController.clear();
    _calendarController.clear();

    await provider.runInference();
  }
}

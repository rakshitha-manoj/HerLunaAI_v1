import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/cycle_log.dart';
import '../widgets/phase_probability_chart.dart';
import '../widgets/confidence_indicator.dart';

/// Cycle Intelligence screen with phase probabilities,
/// cycle log entry, and uncertainty visualization.
class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});

  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
  DateTime? _selectedDate;
  final _cycleLengthController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Intelligence')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Phase Probability Chart ───────────────────────────────
            if (result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PhaseProbabilityChart(
                    phaseProbability: result.phaseProbability,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ── Confidence ────────────────────────────────────────────
            if (result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ConfidenceIndicator(
                        confidence: result.confidenceScore,
                        size: 60,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dominant Phase: ${result.phaseProbability.dominantPhase}',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (!provider.isYoungGirlMode)
                              Text(
                                'Fertility: ${(result.fertilityProbability * 100).toStringAsFixed(1)}%',
                                style: theme.textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ── Log New Cycle ─────────────────────────────────────────
            Text(
              'Log Period Start',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                    TextField(
                      controller: _cycleLengthController,
                      decoration: InputDecoration(
                        labelText: 'Cycle Length (days, optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _selectedDate == null ? null : _addLog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Cycle Log'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Recent Cycle Logs ─────────────────────────────────────
            Text(
              'Recent Cycle Logs',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.cycleLogs.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No cycle logs yet'),
                  subtitle: Text('Add your first period start date above.'),
                ),
              )
            else
              ...provider.cycleLogs.take(10).map((log) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.circle, color: Color(0xFFEF4444), size: 12),
                      title: Text(
                        '${log.periodStart.day}/${log.periodStart.month}/${log.periodStart.year}',
                      ),
                      subtitle: Text(
                        log.cycleLength != null
                            ? 'Cycle length: ${log.cycleLength} days'
                            : 'Cycle length: not recorded',
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _addLog() async {
    if (_selectedDate == null) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final cycleLength = int.tryParse(_cycleLengthController.text);

    await provider.addCycleLog(CycleLog(
      userId: provider.currentUser?.id ?? 0,
      periodStart: _selectedDate!,
      cycleLength: cycleLength,
    ));

    _cycleLengthController.clear();
    setState(() => _selectedDate = null);

    await provider.runInference();
  }
}

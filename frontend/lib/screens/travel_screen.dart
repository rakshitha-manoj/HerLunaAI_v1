import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/travel_data.dart';

/// Travel screen showing travel risk assessment and travel date logging.
class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Travel Risk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Travel Risk Score ──────────────────────────────────────
            if (result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel Risk Score',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${(result.travelRisk * 100).toInt()}%',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: result.travelRisk > 0.5
                                  ? Colors.red
                                  : const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.travelRisk > 0.5
                                      ? 'High overlap probability'
                                      : result.travelRisk > 0.2
                                          ? 'Moderate overlap risk'
                                          : 'Low travel risk',
                                  style: theme.textTheme.titleSmall,
                                ),
                                Text(
                                  'Overlap between travel and physiologically demanding phases.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: result.travelRisk,
                          minHeight: 10,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            result.travelRisk > 0.5
                                ? Colors.red
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // ── Log Travel ────────────────────────────────────────────
            Text(
              'Log Travel Period',
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
                      leading: const Icon(Icons.flight_takeoff),
                      title: Text(
                        _startDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Select start date',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.flight_land),
                      title: Text(
                        _endDate != null
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Select end date',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: (_startDate != null && _endDate != null)
                            ? _addTravel
                            : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Travel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Travel History ────────────────────────────────────────
            Text(
              'Travel History',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (provider.travelData.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No travel data yet'),
                  subtitle: Text('Add upcoming travel dates above.'),
                ),
              )
            else
              ...provider.travelData.map((t) => Card(
                    child: ListTile(
                      leading: Icon(Icons.flight, color: theme.colorScheme.primary),
                      title: Text(
                        '${t.startDate.day}/${t.startDate.month}/${t.startDate.year} — '
                        '${t.endDate.day}/${t.endDate.month}/${t.endDate.year}',
                      ),
                      subtitle: Text(
                        '${t.endDate.difference(t.startDate).inDays + 1} days',
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _addTravel() async {
    if (_startDate == null || _endDate == null) return;
    final provider = Provider.of<AppProvider>(context, listen: false);

    await provider.addTravelData(TravelData(
      userId: provider.currentUser?.id ?? 0,
      startDate: _startDate!,
      endDate: _endDate!,
    ));

    setState(() {
      _startDate = null;
      _endDate = null;
    });

    await provider.runInference();
  }
}

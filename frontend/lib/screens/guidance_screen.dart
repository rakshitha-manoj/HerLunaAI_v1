import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

/// Guidance screen showing dynamic AI suggestions with explainability.
class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppProvider>(context);
    final result = provider.inferenceResult;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Guidance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Card(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: theme.colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized Suggestions',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Generated dynamically from your data and multi-agent analysis.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Guidance Cards ────────────────────────────────────────
            if (result != null && result.guidance.isNotEmpty) ...[
              ...result.guidance.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _getCategoryIcon(g.category, theme),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    g.category,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(g.suggestion, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 16, color: theme.hintColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      g.reason,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.hintColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],

            if (result == null || result.guidance.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.lightbulb_outline,
                        size: 64, color: theme.hintColor),
                    const SizedBox(height: 12),
                    Text(
                      'No guidance available yet.',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      'Add more data for personalized suggestions.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

            // ── Disclaimers ────────────────────────────────────────────
            if (result != null && result.disclaimers.isNotEmpty) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.amber.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Disclaimers',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...result.disclaimers.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $d',
                                style: theme.textTheme.bodySmall),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category, ThemeData theme) {
    IconData icon;
    Color color;

    switch (category.toLowerCase()) {
      case 'cycle phase':
        icon = Icons.auto_graph;
        color = const Color(0xFF8B5CF6);
        break;
      case 'energy':
        icon = Icons.flash_on;
        color = const Color(0xFFF59E0B);
        break;
      case 'wellbeing':
        icon = Icons.spa;
        color = const Color(0xFF10B981);
        break;
      case 'travel':
        icon = Icons.flight;
        color = const Color(0xFF3B82F6);
        break;
      case 'attention':
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case 'cycle awareness':
        icon = Icons.favorite;
        color = const Color(0xFFEF4444);
        break;
      case 'education':
        icon = Icons.school;
        color = const Color(0xFF6366F1);
        break;
      default:
        icon = Icons.lightbulb;
        color = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

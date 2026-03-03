import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final result = provider.inferenceResult;
            final phase = _dominantPhase(result);
            final confidence = result?.meta?.confidenceScore ?? 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: HerLunaTheme.horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Planner', style: HerLunaTheme.heading2),
                  const SizedBox(height: 24),

                  // ── Hero Card ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: HerLunaTheme.heroGradient,
                      borderRadius:
                          BorderRadius.circular(HerLunaTheme.cardRadius),
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
                        Text(
                          'Upcoming Phase',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _nextPhase(phase),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phaseDate(phase),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Confidence',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: confidence,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
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
                  ),
                  const SizedBox(height: 16),

                  // ── Energy Outlook ────────────────────────────────
                  _outlookCard(
                    icon: Icons.bolt_outlined,
                    title: 'Energy Outlook',
                    description: _energyOutlook(phase),
                  ),
                  const SizedBox(height: 12),

                  // ── Stress Outlook ────────────────────────────────
                  _outlookCard(
                    icon: Icons.spa_outlined,
                    title: 'Stress Outlook',
                    description: _stressOutlook(phase),
                  ),
                  const SizedBox(height: 12),

                  // ── Guidance ──────────────────────────────────────
                  HerLunaCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: HerLunaTheme.primary, size: 20),
                            const SizedBox(width: 10),
                            Text('Guidance',
                                style: HerLunaTheme.heading3
                                    .copyWith(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...((result?.meta?.guidance
                                    ?.map<Widget>((g) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(Icons.circle,
                                                  size: 5,
                                                  color: HerLunaTheme.accent),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  g.suggestion ?? '',
                                                  style: HerLunaTheme
                                                      .bodyMedium,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList() as List<Widget>?) ??
                            [
                              Text(
                                'Run inference for personalized guidance.',
                                style: HerLunaTheme.bodySmall,
                              ),
                            ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _outlookCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return HerLunaCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: HerLunaTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: HerLunaTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: HerLunaTheme.heading3.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(description, style: HerLunaTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dominantPhase(dynamic r) {
    if (r == null) return 'Unknown';
    final ps = r.physiologicalState?.phaseProbability;
    if (ps == null) return 'Unknown';
    final map = {
      'Menstrual': ps.menstrual,
      'Follicular': ps.follicular,
      'Ovulatory': ps.ovulatory,
      'Luteal': ps.luteal,
    };
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _nextPhase(String current) {
    const order = ['Menstrual', 'Follicular', 'Ovulatory', 'Luteal'];
    final idx = order.indexOf(current);
    return idx >= 0 ? order[(idx + 1) % 4] : 'Follicular';
  }

  String _phaseDate(String current) {
    // Estimated from current phase
    final days = current == 'Menstrual'
        ? 5
        : current == 'Follicular'
            ? 9
            : current == 'Ovulatory'
                ? 3
                : 10;
    final est = DateTime.now().add(Duration(days: days));
    return 'Estimated ~${est.day}/${est.month}';
  }

  String _energyOutlook(String phase) {
    switch (phase) {
      case 'Menstrual': return 'Energy likely increasing as menstruation ends.';
      case 'Follicular': return 'Rising energy — good window for high-effort tasks.';
      case 'Ovulatory': return 'Peak energy expected in coming days.';
      case 'Luteal': return 'Energy may gradually decrease. Plan accordingly.';
      default: return 'Gathering data for outlook.';
    }
  }

  String _stressOutlook(String phase) {
    switch (phase) {
      case 'Menstrual': return 'Stress resilience typically improves.';
      case 'Follicular': return 'Generally lower stress sensitivity.';
      case 'Ovulatory': return 'Social activities may feel easier.';
      case 'Luteal': return 'Higher sensitivity possible. Consider lighter schedule.';
      default: return 'Gathering data for outlook.';
    }
  }
}

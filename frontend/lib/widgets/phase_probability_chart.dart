import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/inference_response.dart';

/// Reusable bar chart widget for phase probability visualization.
/// Shows four bars: Menstrual, Follicular, Ovulatory, Luteal.
class PhaseProbabilityChart extends StatelessWidget {
  final PhaseProbability phaseProbability;

  const PhaseProbabilityChart({
    super.key,
    required this.phaseProbability,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phases = [
      _PhaseData('Menstrual', phaseProbability.menstrual, const Color(0xFFEF4444)),
      _PhaseData('Follicular', phaseProbability.follicular, const Color(0xFF10B981)),
      _PhaseData('Ovulatory', phaseProbability.ovulatory, const Color(0xFFF59E0B)),
      _PhaseData('Luteal', phaseProbability.luteal, const Color(0xFF8B5CF6)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase Probability',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1.0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${phases[groupIndex].name}\n${(rod.toY * 100).toStringAsFixed(1)}%',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < phases.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            phases[idx].name.substring(0, 3),
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${(value * 100).toInt()}%',
                        style: theme.textTheme.bodySmall,
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                horizontalInterval: 0.25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.dividerColor.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: phases.asMap().entries.map((entry) {
                final idx = entry.key;
                final phase = entry.value;
                return BarChartGroupData(
                  x: idx,
                  barRods: [
                    BarChartRodData(
                      toY: phase.value,
                      color: phase.color,
                      width: 32,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 1.0,
                        color: phase.color.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 16,
          children: phases.map((p) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: p.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(p.name, style: theme.textTheme.bodySmall),
            ],
          )).toList(),
        ),
      ],
    );
  }
}

class _PhaseData {
  final String name;
  final double value;
  final Color color;
  _PhaseData(this.name, this.value, this.color);
}

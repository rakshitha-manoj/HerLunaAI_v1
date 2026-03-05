import 'package:flutter/material.dart';

/// Visual confidence score indicator.
/// Shows a colored arc or bar representing the model's confidence level.
class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double size;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.size = 80,
  });

  Color get _color {
    if (confidence >= 0.7) return const Color(0xFF10B981);
    if (confidence >= 0.4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String get _label {
    if (confidence >= 0.7) return 'High';
    if (confidence >= 0.4) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: confidence,
                  strokeWidth: 8,
                  backgroundColor: _color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                ),
              ),
              Text(
                '${(confidence * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$_label Confidence',
          style: theme.textTheme.bodySmall?.copyWith(
            color: _color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

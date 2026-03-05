/// HerLuna Prediction / Inference Response Model
/// Maps to the backend's nested inference response schema.
class PredictionModel {
  final PhysiologicalState physiologicalState;
  final PerformanceState performanceState;
  final RiskState riskState;
  final InferenceMeta meta;

  PredictionModel({
    required this.physiologicalState,
    required this.performanceState,
    required this.riskState,
    required this.meta,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      physiologicalState: PhysiologicalState.fromJson(
          json['physiological_state'] ?? {}),
      performanceState:
          PerformanceState.fromJson(json['performance_state'] ?? {}),
      riskState: RiskState.fromJson(json['risk_state'] ?? {}),
      meta: InferenceMeta.fromJson(json['meta'] ?? {}),
    );
  }

  // ── Convenience Getters ──────────────────────────────────────────────
  String get dominantPhase => physiologicalState.dominantPhase;
  double get confidenceScore => meta.confidenceScore;
  double get fatigueProbability => performanceState.fatigueProbability;
  double get stressProbability => riskState.stressProbability;
  double get readinessScore => performanceState.readinessScore;
}

class PhysiologicalState {
  final PhaseProbability phaseProbability;
  final int estimatedDayInCycle;

  PhysiologicalState({
    required this.phaseProbability,
    this.estimatedDayInCycle = 0,
  });

  factory PhysiologicalState.fromJson(Map<String, dynamic> json) {
    return PhysiologicalState(
      phaseProbability: PhaseProbability.fromJson(
          json['phase_probability'] ?? {}),
      estimatedDayInCycle: json['estimated_day_in_cycle'] ?? 0,
    );
  }

  String get dominantPhase {
    final map = {
      'Menstrual': phaseProbability.menstrual,
      'Follicular': phaseProbability.follicular,
      'Ovulatory': phaseProbability.ovulatory,
      'Luteal': phaseProbability.luteal,
    };
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

class PhaseProbability {
  final double menstrual;
  final double follicular;
  final double ovulatory;
  final double luteal;

  PhaseProbability({
    this.menstrual = 0.25,
    this.follicular = 0.25,
    this.ovulatory = 0.25,
    this.luteal = 0.25,
  });

  factory PhaseProbability.fromJson(Map<String, dynamic> json) {
    return PhaseProbability(
      menstrual: (json['menstrual'] ?? 0.25).toDouble(),
      follicular: (json['follicular'] ?? 0.25).toDouble(),
      ovulatory: (json['ovulatory'] ?? 0.25).toDouble(),
      luteal: (json['luteal'] ?? 0.25).toDouble(),
    );
  }
}

class PerformanceState {
  final double fatigueProbability;
  final double readinessScore;

  PerformanceState({
    this.fatigueProbability = 0.0,
    this.readinessScore = 0.0,
  });

  factory PerformanceState.fromJson(Map<String, dynamic> json) {
    return PerformanceState(
      fatigueProbability: (json['fatigue_probability'] ?? 0.0).toDouble(),
      readinessScore: (json['readiness_score'] ?? 0.0).toDouble(),
    );
  }
}

class RiskState {
  final double stressProbability;
  final bool anomalyFlag;

  RiskState({
    this.stressProbability = 0.0,
    this.anomalyFlag = false,
  });

  factory RiskState.fromJson(Map<String, dynamic> json) {
    return RiskState(
      stressProbability: (json['stress_probability'] ?? 0.0).toDouble(),
      anomalyFlag: json['anomaly_flag'] ?? false,
    );
  }
}

class BaselineMetrics {
  final double? meanCycleLength;
  final double? cycleVariabilityIndex;
  final double? behavioralDeviationScore;

  BaselineMetrics({
    this.meanCycleLength,
    this.cycleVariabilityIndex,
    this.behavioralDeviationScore,
  });

  factory BaselineMetrics.fromJson(Map<String, dynamic> json) {
    return BaselineMetrics(
      meanCycleLength: (json['mean_cycle_length'] as num?)?.toDouble(),
      cycleVariabilityIndex: (json['cycle_variability_index'] as num?)?.toDouble(),
      behavioralDeviationScore: (json['behavioral_deviation_score'] as num?)?.toDouble(),
    );
  }
}

class InferenceMeta {
  final double confidenceScore;
  final String inferenceMode;
  final BaselineMetrics baselineMetrics;
  final List<Guidance> guidance;

  InferenceMeta({
    this.confidenceScore = 0.0,
    this.inferenceMode = 'unknown',
    BaselineMetrics? baselineMetrics,
    this.guidance = const [],
  }) : baselineMetrics = baselineMetrics ?? BaselineMetrics();

  factory InferenceMeta.fromJson(Map<String, dynamic> json) {
    return InferenceMeta(
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      inferenceMode: json['inference_mode'] ?? 'unknown',
      baselineMetrics: BaselineMetrics.fromJson(json['baseline_metrics'] ?? {}),
      guidance: (json['guidance'] as List<dynamic>?)
              ?.map((g) => Guidance.fromJson(g))
              .toList() ??
          [],
    );
  }
}

class Guidance {
  final String category;
  final String suggestion;

  Guidance({required this.category, required this.suggestion});

  factory Guidance.fromJson(Map<String, dynamic> json) {
    return Guidance(
      category: json['category'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }
}

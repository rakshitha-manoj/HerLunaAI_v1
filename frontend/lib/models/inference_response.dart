/// HerLuna Inference Response Model
/// Mirrors the backend's nested InferenceResponse JSON contract.
/// v2.0.0 — matches multi-agent architecture.
library;

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

  String get dominantPhase {
    final phases = {
      'Menstrual': menstrual,
      'Follicular': follicular,
      'Ovulatory': ovulatory,
      'Luteal': luteal,
    };
    return phases.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}

class PhysiologicalState {
  final PhaseProbability phaseProbability;
  final double fertilityProbability;

  PhysiologicalState({
    PhaseProbability? phaseProbability,
    this.fertilityProbability = 0.0,
  }) : phaseProbability = phaseProbability ?? PhaseProbability();

  factory PhysiologicalState.fromJson(Map<String, dynamic> json) {
    return PhysiologicalState(
      phaseProbability: json['phase_probability'] != null
          ? PhaseProbability.fromJson(json['phase_probability'])
          : PhaseProbability(),
      fertilityProbability:
          (json['fertility_probability'] ?? 0.0).toDouble(),
    );
  }
}

class PerformanceState {
  final double fatigueProbability;
  final double readinessScore;

  PerformanceState({
    this.fatigueProbability = 0.0,
    this.readinessScore = 50.0,
  });

  factory PerformanceState.fromJson(Map<String, dynamic> json) {
    return PerformanceState(
      fatigueProbability: (json['fatigue_probability'] ?? 0.0).toDouble(),
      readinessScore: (json['readiness_score'] ?? 50.0).toDouble(),
    );
  }
}

class RiskState {
  final double stressProbability;
  final double travelRisk;
  final bool anomalyFlag;

  RiskState({
    this.stressProbability = 0.0,
    this.travelRisk = 0.0,
    this.anomalyFlag = false,
  });

  factory RiskState.fromJson(Map<String, dynamic> json) {
    return RiskState(
      stressProbability: (json['stress_probability'] ?? 0.0).toDouble(),
      travelRisk: (json['travel_risk'] ?? 0.0).toDouble(),
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
      meanCycleLength: json['mean_cycle_length']?.toDouble(),
      cycleVariabilityIndex: json['cycle_variability_index']?.toDouble(),
      behavioralDeviationScore:
          json['behavioral_deviation_score']?.toDouble(),
    );
  }
}

class GuidanceSuggestion {
  final String category;
  final String suggestion;
  final String reason;

  GuidanceSuggestion({
    required this.category,
    required this.suggestion,
    required this.reason,
  });

  factory GuidanceSuggestion.fromJson(Map<String, dynamic> json) {
    return GuidanceSuggestion(
      category: json['category'] ?? '',
      suggestion: json['suggestion'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class InferenceMeta {
  final double confidenceScore;
  final BaselineMetrics baselineMetrics;
  final String modelVersion;
  final int inferenceTimeMs;
  final List<String> topFeatures;
  final List<String> trendFlags;
  final List<GuidanceSuggestion> guidance;
  final List<String> disclaimers;

  InferenceMeta({
    this.confidenceScore = 0.0,
    BaselineMetrics? baselineMetrics,
    this.modelVersion = 'v1.0.0',
    this.inferenceTimeMs = 0,
    this.topFeatures = const [],
    this.trendFlags = const [],
    this.guidance = const [],
    this.disclaimers = const [],
  }) : baselineMetrics = baselineMetrics ?? BaselineMetrics();

  factory InferenceMeta.fromJson(Map<String, dynamic> json) {
    return InferenceMeta(
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      baselineMetrics: json['baseline_metrics'] != null
          ? BaselineMetrics.fromJson(json['baseline_metrics'])
          : BaselineMetrics(),
      modelVersion: json['model_version'] ?? 'v1.0.0',
      inferenceTimeMs: json['inference_time_ms'] ?? 0,
      topFeatures: List<String>.from(json['top_features'] ?? []),
      trendFlags: List<String>.from(json['trend_flags'] ?? []),
      guidance: (json['guidance'] as List<dynamic>?)
              ?.map((g) => GuidanceSuggestion.fromJson(g))
              .toList() ??
          [],
      disclaimers: List<String>.from(json['disclaimers'] ?? []),
    );
  }
}

class InferenceResponse {
  final PhysiologicalState physiologicalState;
  final PerformanceState performanceState;
  final RiskState riskState;
  final InferenceMeta meta;

  InferenceResponse({
    PhysiologicalState? physiologicalState,
    PerformanceState? performanceState,
    RiskState? riskState,
    InferenceMeta? meta,
  })  : physiologicalState = physiologicalState ?? PhysiologicalState(),
        performanceState = performanceState ?? PerformanceState(),
        riskState = riskState ?? RiskState(),
        meta = meta ?? InferenceMeta();

  factory InferenceResponse.fromJson(Map<String, dynamic> json) {
    return InferenceResponse(
      physiologicalState: json['physiological_state'] != null
          ? PhysiologicalState.fromJson(json['physiological_state'])
          : PhysiologicalState(),
      performanceState: json['performance_state'] != null
          ? PerformanceState.fromJson(json['performance_state'])
          : PerformanceState(),
      riskState: json['risk_state'] != null
          ? RiskState.fromJson(json['risk_state'])
          : RiskState(),
      meta: json['meta'] != null
          ? InferenceMeta.fromJson(json['meta'])
          : InferenceMeta(),
    );
  }

  // Convenience getters for backward compatibility
  double get fatigueProbability => performanceState.fatigueProbability;
  double get stressProbability => riskState.stressProbability;
  double get readinessScore => performanceState.readinessScore;
  PhaseProbability get phaseProbability =>
      physiologicalState.phaseProbability;
  double get fertilityProbability =>
      physiologicalState.fertilityProbability;
  double get travelRisk => riskState.travelRisk;
  bool get anomalyFlag => riskState.anomalyFlag;
  double get confidenceScore => meta.confidenceScore;
  List<String> get topFeatures => meta.topFeatures;
  List<GuidanceSuggestion> get guidance => meta.guidance;
  List<String> get disclaimers => meta.disclaimers;
}

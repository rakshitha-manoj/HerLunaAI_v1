/// HerLuna Cycle Log Model
class CycleLogModel {
  final int? id;
  final int? userId;
  final DateTime periodStart;
  final int? cycleLength;
  final int? bleedingDays;
  final String? flowIntensity;
  final List<String>? symptoms;
  final String? notes;
  final DateTime? createdAt;

  CycleLogModel({
    this.id,
    this.userId,
    required this.periodStart,
    this.cycleLength,
    this.bleedingDays,
    this.flowIntensity,
    this.symptoms,
    this.notes,
    this.createdAt,
  });

  factory CycleLogModel.fromJson(Map<String, dynamic> json) {
    return CycleLogModel(
      id: json['id'],
      userId: json['user_id'],
      periodStart: DateTime.parse(json['period_start']),
      cycleLength: json['cycle_length'],
      bleedingDays: json['bleeding_days'],
      flowIntensity: json['flow_intensity'],
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'period_start': periodStart.toIso8601String().split('T')[0],
        if (bleedingDays != null) 'bleeding_days': bleedingDays,
        if (flowIntensity != null) 'flow_intensity': flowIntensity,
        if (symptoms != null) 'symptoms': symptoms,
        if (notes != null) 'notes': notes,
      };
}

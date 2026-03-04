/// HerLuna Cycle Log Model
class CycleLogModel {
  final int? id;
  final int userId;
  final DateTime periodStart;
  final int? cycleLength;
  final DateTime? createdAt;

  CycleLogModel({
    this.id,
    required this.userId,
    required this.periodStart,
    this.cycleLength,
    this.createdAt,
  });

  factory CycleLogModel.fromJson(Map<String, dynamic> json) {
    return CycleLogModel(
      id: json['id'],
      userId: json['user_id'],
      periodStart: DateTime.parse(json['period_start']),
      cycleLength: json['cycle_length'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'period_start': periodStart.toIso8601String().split('T')[0],
        'cycle_length': cycleLength,
      };
}

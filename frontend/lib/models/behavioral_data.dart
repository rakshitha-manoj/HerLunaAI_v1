/// HerLuna Behavioral Data Model
class BehavioralData {
  final int? id;
  final int userId;
  final int stepCount;
  final double screenTime;
  final int calendarLoad;
  final DateTime date;

  BehavioralData({
    this.id,
    required this.userId,
    required this.stepCount,
    required this.screenTime,
    required this.calendarLoad,
    required this.date,
  });

  factory BehavioralData.fromJson(Map<String, dynamic> json) {
    return BehavioralData(
      id: json['id'],
      userId: json['user_id'],
      stepCount: json['step_count'] ?? 0,
      screenTime: (json['screen_time'] ?? 0.0).toDouble(),
      calendarLoad: json['calendar_load'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'step_count': stepCount,
        'screen_time': screenTime,
        'calendar_load': calendarLoad,
        'date': date.toIso8601String().split('T')[0],
      };
}

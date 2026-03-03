/// HerLuna Travel Data Model
class TravelData {
  final int? id;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;

  TravelData({
    this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  factory TravelData.fromJson(Map<String, dynamic> json) {
    return TravelData(
      id: json['id'],
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
      };
}

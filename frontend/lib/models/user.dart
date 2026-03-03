/// HerLuna User Model
class User {
  final int id;
  final String email;
  final String storageMode;
  final bool isYoungGirlMode;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.storageMode,
    this.isYoungGirlMode = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      storageMode: json['storage_mode'] ?? 'cloud',
      isYoungGirlMode: json['is_young_girl_mode'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'storage_mode': storageMode,
        'is_young_girl_mode': isYoungGirlMode,
        'created_at': createdAt.toIso8601String(),
      };
}

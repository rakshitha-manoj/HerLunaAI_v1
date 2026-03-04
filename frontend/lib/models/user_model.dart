/// HerLuna User Model
class UserModel {
  final int id;
  final String email;
  final String? name;
  final String storageMode;
  final bool isYoungGirlMode;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.storageMode,
    this.isYoungGirlMode = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      storageMode: json['storage_mode'] ?? 'cloud',
      isYoungGirlMode: json['is_young_girl_mode'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'storage_mode': storageMode,
        'is_young_girl_mode': isYoungGirlMode,
        'created_at': createdAt.toIso8601String(),
      };
}

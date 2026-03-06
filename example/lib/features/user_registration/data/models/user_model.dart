import '../../domain/entities/user_entity.dart';

/// Data model extending [UserEntity] — handles JSON deserialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.gender,
    required super.birthDate,
    required super.avatar,
    required super.department,
    required super.company,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final companyMap = json['company'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      avatar: json['image'] as String? ?? '',
      department: companyMap['department'] as String? ?? '',
      company: companyMap['name'] as String? ?? '',
    );
  }
}

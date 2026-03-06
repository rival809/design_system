import '../../domain/entities/created_user_entity.dart';

/// Data model extending [CreatedUserEntity] — handles JSON deserialization
/// from the POST /users/add response.
class CreatedUserModel extends CreatedUserEntity {
  const CreatedUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.gender,
    required super.birthDate,
    required super.department,
    required super.company,
  });

  factory CreatedUserModel.fromJson(Map<String, dynamic> json) {
    final companyMap = json['company'] as Map<String, dynamic>? ?? {};
    return CreatedUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      department: companyMap['department'] as String? ?? '',
      company: companyMap['name'] as String? ?? '',
    );
  }
}

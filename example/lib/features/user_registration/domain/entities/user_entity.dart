import 'package:equatable/equatable.dart';

/// Domain entity representing a user fetched from the API.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.avatar,
    required this.department,
    required this.company,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final String avatar;
  final String department;
  final String company;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    gender,
    birthDate,
    department,
    company,
  ];
}

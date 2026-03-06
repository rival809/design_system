import 'package:equatable/equatable.dart';

/// Domain entity representing a newly created user returned by the API.
class CreatedUserEntity extends Equatable {
  const CreatedUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.department,
    required this.company,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String birthDate;
  final String department;
  final String company;

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    gender,
    birthDate,
    department,
    company,
  ];
}

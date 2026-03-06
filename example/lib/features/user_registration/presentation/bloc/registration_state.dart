import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../domain/entities/created_user_entity.dart';
import 'registration_inputs.dart';

enum RegistrationStatus { initial, loading, success, failure }

class RegistrationState extends Equatable {
  const RegistrationState({
    this.fullName = const FullNameInput.pure(),
    this.email = const EmailInput.pure(),
    this.phone = const PhoneInput.pure(),
    this.jobTitle = const JobTitleInput.pure(),
    this.department = const DepartmentInput.pure(),
    this.dateOfBirth,
    this.gender = 'male',
    this.salary = '',
    this.bio = const BioInput.pure(),
    this.password = const PasswordInput.pure(),
    this.confirmPassword = const ConfirmPasswordInput.pure(),
    this.termsAccepted = false,
    this.newsletterSubscribed = false,
    this.status = RegistrationStatus.initial,
    this.errorMessage,
    this.createdUser,
  });

  final FullNameInput fullName;
  final EmailInput email;
  final PhoneInput phone;
  final JobTitleInput jobTitle;
  final DepartmentInput department;
  final DateTime? dateOfBirth;
  final String gender;
  final String salary;
  final BioInput bio;
  final PasswordInput password;
  final ConfirmPasswordInput confirmPassword;
  final bool termsAccepted;
  final bool newsletterSubscribed;
  final RegistrationStatus status;
  final String? errorMessage;
  final CreatedUserEntity? createdUser;

  bool get isValid =>
      Formz.validate([
        fullName,
        email,
        phone,
        jobTitle,
        department,
        bio,
        password,
        confirmPassword,
      ]) &&
      termsAccepted &&
      dateOfBirth != null;

  int get passwordStrength {
    final v = password.value;
    if (v.isEmpty) return 0;
    int score = 0;
    if (v.length >= 8) score++;
    if (v.contains(RegExp(r'[A-Z]'))) score++;
    if (v.contains(RegExp(r'[0-9]'))) score++;
    if (v.contains(RegExp(r'[!@#\$&*~]'))) score++;
    return score;
  }

  RegistrationState copyWith({
    FullNameInput? fullName,
    EmailInput? email,
    PhoneInput? phone,
    JobTitleInput? jobTitle,
    DepartmentInput? department,
    DateTime? dateOfBirth,
    bool clearDateOfBirth = false,
    String? gender,
    String? salary,
    BioInput? bio,
    PasswordInput? password,
    ConfirmPasswordInput? confirmPassword,
    bool? termsAccepted,
    bool? newsletterSubscribed,
    RegistrationStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    CreatedUserEntity? createdUser,
    bool clearCreatedUser = false,
  }) {
    return RegistrationState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      dateOfBirth: clearDateOfBirth ? null : (dateOfBirth ?? this.dateOfBirth),
      gender: gender ?? this.gender,
      salary: salary ?? this.salary,
      bio: bio ?? this.bio,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      status: status ?? this.status,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdUser: clearCreatedUser ? null : (createdUser ?? this.createdUser),
    );
  }

  @override
  List<Object?> get props => [
    fullName,
    email,
    phone,
    jobTitle,
    department,
    dateOfBirth,
    gender,
    salary,
    bio,
    password,
    confirmPassword,
    termsAccepted,
    newsletterSubscribed,
    status,
    errorMessage,
    createdUser,
  ];
}

import 'package:equatable/equatable.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

final class RegistrationFullNameChanged extends RegistrationEvent {
  const RegistrationFullNameChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationEmailChanged extends RegistrationEvent {
  const RegistrationEmailChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationPhoneChanged extends RegistrationEvent {
  const RegistrationPhoneChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationJobTitleChanged extends RegistrationEvent {
  const RegistrationJobTitleChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationDepartmentChanged extends RegistrationEvent {
  const RegistrationDepartmentChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationDateOfBirthChanged extends RegistrationEvent {
  const RegistrationDateOfBirthChanged(this.value);
  final DateTime value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationGenderChanged extends RegistrationEvent {
  const RegistrationGenderChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationSalaryChanged extends RegistrationEvent {
  const RegistrationSalaryChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationBioChanged extends RegistrationEvent {
  const RegistrationBioChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationPasswordChanged extends RegistrationEvent {
  const RegistrationPasswordChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationConfirmPasswordChanged extends RegistrationEvent {
  const RegistrationConfirmPasswordChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationTermsChanged extends RegistrationEvent {
  const RegistrationTermsChanged({required this.value});
  final bool value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationNewsletterChanged extends RegistrationEvent {
  const RegistrationNewsletterChanged({required this.value});
  final bool value;
  @override
  List<Object?> get props => [value];
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}

final class RegistrationReset extends RegistrationEvent {
  const RegistrationReset();
}

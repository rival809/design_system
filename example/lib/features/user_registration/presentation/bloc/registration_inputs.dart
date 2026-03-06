import 'package:formz/formz.dart';

// ─── Full Name ───────────────────────────────────────────────────────────────

enum FullNameError { empty, tooShort }

class FullNameInput extends FormzInput<String, FullNameError> {
  const FullNameInput.pure() : super.pure('');
  const FullNameInput.dirty([super.value = '']) : super.dirty();

  @override
  FullNameError? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return FullNameError.empty;
    if (trimmed.length < 3) return FullNameError.tooShort;
    return null;
  }
}

// ─── Email ────────────────────────────────────────────────────────────────────

enum EmailError { empty, invalid }

class EmailInput extends FormzInput<String, EmailError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  @override
  EmailError? validator(String value) {
    if (value.trim().isEmpty) return EmailError.empty;
    if (!_emailRegex.hasMatch(value.trim())) return EmailError.invalid;
    return null;
  }
}

// ─── Phone ────────────────────────────────────────────────────────────────────

enum PhoneError { empty, invalid }

class PhoneInput extends FormzInput<String, PhoneError> {
  const PhoneInput.pure() : super.pure('');
  const PhoneInput.dirty([super.value = '']) : super.dirty();

  @override
  PhoneError? validator(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return PhoneError.empty;
    if (digits.length < 10) return PhoneError.invalid;
    return null;
  }
}

// ─── Job Title ────────────────────────────────────────────────────────────────

enum JobTitleError { empty }

class JobTitleInput extends FormzInput<String, JobTitleError> {
  const JobTitleInput.pure() : super.pure('');
  const JobTitleInput.dirty([super.value = '']) : super.dirty();

  @override
  JobTitleError? validator(String value) => value.trim().isEmpty ? JobTitleError.empty : null;
}

// ─── Department ───────────────────────────────────────────────────────────────

enum DepartmentError { empty }

class DepartmentInput extends FormzInput<String, DepartmentError> {
  const DepartmentInput.pure() : super.pure('');
  const DepartmentInput.dirty([super.value = '']) : super.dirty();

  @override
  DepartmentError? validator(String value) => value.trim().isEmpty ? DepartmentError.empty : null;
}

// ─── Password ─────────────────────────────────────────────────────────────────

enum PasswordError { empty, tooShort, noUpperCase, noDigit }

class PasswordInput extends FormzInput<String, PasswordError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty) return PasswordError.empty;
    if (value.length < 8) return PasswordError.tooShort;
    if (!value.contains(RegExp(r'[A-Z]'))) return PasswordError.noUpperCase;
    if (!value.contains(RegExp(r'[0-9]'))) return PasswordError.noDigit;
    return null;
  }
}

// ─── Confirm Password ─────────────────────────────────────────────────────────

enum ConfirmPasswordError { empty, mismatch }

typedef ConfirmPasswordValue = ({String value, String password});

class ConfirmPasswordInput extends FormzInput<ConfirmPasswordValue, ConfirmPasswordError> {
  const ConfirmPasswordInput.pure() : super.pure((value: '', password: ''));

  const ConfirmPasswordInput.dirty({required String value, required String password})
    : super.dirty((value: value, password: password));

  @override
  ConfirmPasswordError? validator(ConfirmPasswordValue v) {
    if (v.value.isEmpty) return ConfirmPasswordError.empty;
    if (v.value != v.password) return ConfirmPasswordError.mismatch;
    return null;
  }
}

// ─── Bio ──────────────────────────────────────────────────────────────────────

enum BioError { tooLong }

class BioInput extends FormzInput<String, BioError> {
  const BioInput.pure() : super.pure('');
  const BioInput.dirty([super.value = '']) : super.dirty();

  static const int maxLength = 300;

  @override
  BioError? validator(String value) => value.length > maxLength ? BioError.tooLong : null;
}

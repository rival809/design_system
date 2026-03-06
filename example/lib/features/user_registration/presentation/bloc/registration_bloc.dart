import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_user_usecase.dart';
import 'registration_event.dart';
import 'registration_inputs.dart';
import 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({required CreateUserUseCase createUserUseCase})
    : _createUserUseCase = createUserUseCase,
      super(const RegistrationState()) {
    on<RegistrationFullNameChanged>(_onFullNameChanged);
    on<RegistrationEmailChanged>(_onEmailChanged);
    on<RegistrationPhoneChanged>(_onPhoneChanged);
    on<RegistrationJobTitleChanged>(_onJobTitleChanged);
    on<RegistrationDepartmentChanged>(_onDepartmentChanged);
    on<RegistrationDateOfBirthChanged>(_onDateOfBirthChanged);
    on<RegistrationGenderChanged>(_onGenderChanged);
    on<RegistrationSalaryChanged>(_onSalaryChanged);
    on<RegistrationBioChanged>(_onBioChanged);
    on<RegistrationPasswordChanged>(_onPasswordChanged);
    on<RegistrationConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegistrationTermsChanged>(_onTermsChanged);
    on<RegistrationNewsletterChanged>(_onNewsletterChanged);
    on<RegistrationSubmitted>(_onSubmitted);
    on<RegistrationReset>(_onReset);
  }

  final CreateUserUseCase _createUserUseCase;

  void _onFullNameChanged(RegistrationFullNameChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(fullName: FullNameInput.dirty(event.value)));

  void _onEmailChanged(RegistrationEmailChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(email: EmailInput.dirty(event.value)));

  void _onPhoneChanged(RegistrationPhoneChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(phone: PhoneInput.dirty(event.value)));

  void _onJobTitleChanged(RegistrationJobTitleChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(jobTitle: JobTitleInput.dirty(event.value)));

  void _onDepartmentChanged(RegistrationDepartmentChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(department: DepartmentInput.dirty(event.value)));

  void _onDateOfBirthChanged(
    RegistrationDateOfBirthChanged event,
    Emitter<RegistrationState> emit,
  ) => emit(state.copyWith(dateOfBirth: event.value));

  void _onGenderChanged(RegistrationGenderChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(gender: event.value));

  void _onSalaryChanged(RegistrationSalaryChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(salary: event.value));

  void _onBioChanged(RegistrationBioChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(bio: BioInput.dirty(event.value)));

  void _onPasswordChanged(RegistrationPasswordChanged event, Emitter<RegistrationState> emit) {
    final newPassword = PasswordInput.dirty(event.value);
    // Re-validate confirm password against the new password value
    final newConfirm = state.confirmPassword.isPure
        ? state.confirmPassword
        : ConfirmPasswordInput.dirty(
            value: state.confirmPassword.value.value,
            password: event.value,
          );
    emit(state.copyWith(password: newPassword, confirmPassword: newConfirm));
  }

  void _onConfirmPasswordChanged(
    RegistrationConfirmPasswordChanged event,
    Emitter<RegistrationState> emit,
  ) => emit(
    state.copyWith(
      confirmPassword: ConfirmPasswordInput.dirty(
        value: event.value,
        password: state.password.value,
      ),
    ),
  );

  void _onTermsChanged(RegistrationTermsChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(termsAccepted: event.value));

  void _onNewsletterChanged(RegistrationNewsletterChanged event, Emitter<RegistrationState> emit) =>
      emit(state.copyWith(newsletterSubscribed: event.value));

  Future<void> _onSubmitted(RegistrationSubmitted event, Emitter<RegistrationState> emit) async {
    // Mark all inputs dirty to trigger validation UI
    final dirtyState = state.copyWith(
      fullName: FullNameInput.dirty(state.fullName.value),
      email: EmailInput.dirty(state.email.value),
      phone: PhoneInput.dirty(state.phone.value),
      jobTitle: JobTitleInput.dirty(state.jobTitle.value),
      department: DepartmentInput.dirty(state.department.value),
      bio: BioInput.dirty(state.bio.value),
      password: PasswordInput.dirty(state.password.value),
      confirmPassword: ConfirmPasswordInput.dirty(
        value: state.confirmPassword.value.value,
        password: state.password.value,
      ),
    );
    emit(dirtyState);

    if (!dirtyState.isValid) return;

    emit(dirtyState.copyWith(status: RegistrationStatus.loading));

    // Format birth date as ISO-8601
    final dob = state.dateOfBirth!;
    final birthDate =
        '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

    // Split full name → firstName + lastName
    final parts = state.fullName.value.trim().split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final result = await _createUserUseCase(
      CreateUserParams(
        firstName: firstName,
        lastName: lastName,
        email: state.email.value,
        phone: state.phone.value,
        gender: state.gender,
        birthDate: birthDate,
        department: state.department.value,
        company: state.jobTitle.value,
      ),
    );

    result.when(
      ok: (user) => emit(
        dirtyState.copyWith(
          status: RegistrationStatus.success,
          createdUser: user,
          clearErrorMessage: true,
        ),
      ),
      err: (failure) => emit(
        dirtyState.copyWith(status: RegistrationStatus.failure, errorMessage: failure.message),
      ),
    );
  }

  void _onReset(RegistrationReset event, Emitter<RegistrationState> emit) =>
      emit(const RegistrationState());
}

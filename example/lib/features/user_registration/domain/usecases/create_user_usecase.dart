import 'package:equatable/equatable.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/created_user_entity.dart';
import '../repositories/user_repository.dart';

/// Parameters required to create a new user.
class CreateUserParams extends Equatable {
  const CreateUserParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.department,
    required this.company,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final String department;
  final String company;

  @override
  List<Object?> get props => [
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

/// Submits a new user registration to the remote data source.
class CreateUserUseCase implements UseCase<CreatedUserEntity, CreateUserParams> {
  const CreateUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<CreatedUserEntity>> call(CreateUserParams params) => _repository.createUser(
    firstName: params.firstName,
    lastName: params.lastName,
    email: params.email,
    phone: params.phone,
    gender: params.gender,
    birthDate: params.birthDate,
    department: params.department,
    company: params.company,
  );
}

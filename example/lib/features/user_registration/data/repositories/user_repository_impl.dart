import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/created_user_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/create_user_request_model.dart';

/// Concrete implementation of [UserRepository].
/// Translates data-layer exceptions into domain [AppFailure] values.
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._remoteDataSource);

  final UserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<UserEntity>>> getUsers({
    int page = 1,
    int limit = 10,
    String query = '',
  }) async {
    try {
      final users = await _remoteDataSource.getUsers(page: page, limit: limit, query: query);
      return Ok(users);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Err(NetworkFailure(e.message));
    } on ParseException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }

  @override
  Future<Result<CreatedUserEntity>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String birthDate,
    required String department,
    required String company,
  }) async {
    try {
      final result = await _remoteDataSource.createUser(
        CreateUserRequestModel(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          gender: gender,
          birthDate: birthDate,
          department: department,
          companyName: company,
        ),
      );
      return Ok(result);
    } on ServerException catch (e) {
      return Err(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Err(NetworkFailure(e.message));
    } on ParseException catch (e) {
      return Err(ServerFailure(e.message));
    } catch (e) {
      return Err(UnknownFailure('Terjadi kesalahan tidak terduga: $e'));
    }
  }
}

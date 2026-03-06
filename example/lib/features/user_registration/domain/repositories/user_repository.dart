import '../../../../core/errors/result.dart';
import '../entities/created_user_entity.dart';
import '../entities/user_entity.dart';

/// Abstract contract for user data — only the domain knows this interface.
/// The data layer provides the concrete implementation.
abstract interface class UserRepository {
  Future<Result<List<UserEntity>>> getUsers({int page, int limit, String query});

  Future<Result<CreatedUserEntity>> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String gender,
    required String birthDate,
    required String department,
    required String company,
  });
}

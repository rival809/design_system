import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUsersParams {
  const GetUsersParams({this.page = 1, this.limit = 10, this.query = ''});

  final int page;
  final int limit;
  final String query;
}

/// Retrieves a paginated list of users from the remote data source.
class GetUsersUseCase implements UseCase<List<UserEntity>, GetUsersParams> {
  const GetUsersUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Result<List<UserEntity>>> call(GetUsersParams params) =>
      _repository.getUsers(page: params.page, limit: params.limit, query: params.query);
}

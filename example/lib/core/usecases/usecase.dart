import '../errors/result.dart';

/// Base contract for all use cases that accept typed [Params].
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base contract for use cases with no parameters.
abstract interface class NoParamsUseCase<T> {
  Future<Result<T>> call();
}

/// Placeholder passed to [UseCase] when no parameters are needed.
final class NoParams {
  const NoParams();
}

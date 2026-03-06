import 'failures.dart';

/// A discriminated union representing either a success [Ok] or a failure [Err].
///
/// Usage:
/// ```dart
/// final result = await repository.getUsers();
/// result.when(
///   ok: (users) => print(users),
///   err: (failure) => print(failure.message),
/// );
/// ```
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Ok() => null,
    Err(:final failure) => failure,
  };

  R when<R>({required R Function(T value) ok, required R Function(AppFailure failure) err}) =>
      switch (this) {
        Ok(:final value) => ok(value),
        Err(:final failure) => err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}

import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

enum UserListStatus { initial, loading, loadingMore, loaded, error }

class UserListState extends Equatable {
  const UserListState({
    this.users = const [],
    this.status = UserListStatus.initial,
    this.hasReachedEnd = false,
    this.query = '',
    this.currentPage = 1,
    this.errorMessage,
  });

  final List<UserEntity> users;
  final UserListStatus status;
  final bool hasReachedEnd;
  final String query;
  final int currentPage;
  final String? errorMessage;

  bool get isInitial => status == UserListStatus.initial;
  bool get isLoading => status == UserListStatus.loading;
  bool get isLoadingMore => status == UserListStatus.loadingMore;
  bool get isLoaded => status == UserListStatus.loaded;
  bool get isError => status == UserListStatus.error;

  // Uses a sentinel so copyWith(errorMessage: null) clears the field.
  static const _unset = Object();

  UserListState copyWith({
    List<UserEntity>? users,
    UserListStatus? status,
    bool? hasReachedEnd,
    String? query,
    int? currentPage,
    Object? errorMessage = _unset,
  }) {
    return UserListState(
      users: users ?? this.users,
      status: status ?? this.status,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      query: query ?? this.query,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [users, status, hasReachedEnd, query, currentPage, errorMessage];
}

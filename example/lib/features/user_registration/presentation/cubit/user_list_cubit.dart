import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_users_usecase.dart';
import 'user_list_state.dart';

class UserListCubit extends Cubit<UserListState> {
  static const _limit = 10;

  UserListCubit({required GetUsersUseCase getUsersUseCase})
    : _getUsersUseCase = getUsersUseCase,
      super(const UserListState());

  final GetUsersUseCase _getUsersUseCase;
  Timer? _debounce;

  /// Initial load (or hard refresh — clears query too).
  Future<void> loadUsers() async {
    emit(const UserListState(status: UserListStatus.loading));
    await _fetch(page: 1);
  }

  /// Soft refresh — keeps the current query.
  Future<void> refresh() async {
    emit(UserListState(query: state.query, status: UserListStatus.loading));
    await _fetch(page: 1);
  }

  /// Debounced server-side search.
  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      emit(UserListState(query: query, status: UserListStatus.loading));
      _fetch(page: 1);
    });
  }

  /// Load next page. Safe to call multiple times — guards prevent double-fetch.
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd) return;
    if (state.isLoading || state.isInitial) return;
    if (state.users.isEmpty) return;
    emit(state.copyWith(status: UserListStatus.loadingMore));
    await _fetch(page: state.currentPage + 1);
  }

  Future<void> _fetch({required int page}) async {
    final result = await _getUsersUseCase(
      GetUsersParams(page: page, limit: _limit, query: state.query),
    );
    result.when(
      ok: (users) {
        final merged = page == 1 ? users : [...state.users, ...users];
        emit(
          state.copyWith(
            status: UserListStatus.loaded,
            users: merged,
            currentPage: page,
            hasReachedEnd: users.length < _limit,
            errorMessage: null,
          ),
        );
      },
      err: (failure) =>
          emit(state.copyWith(status: UserListStatus.error, errorMessage: failure.message)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

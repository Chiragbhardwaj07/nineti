// lib/features/user_management/bloc/user_list_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/features/user_management/domain/models/user.dart';
import 'package:nineti/features/user_management/domain/repository/user_repository.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserRepository _userRepository;

  // Pagination parameters
  static const int _limit = 20;
  int _skip = 0;
  bool _hasMore = true;
  String? _searchQuery;

  // This holds the “accumulated” list of users internally.
  final List<User> _users = [];

  UserListBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserListInitial()) {
    on<UserListFetchInitial>(_onFetchInitial);
    on<UserListFetchMore>(_onFetchMore);
    on<UserListSearch>(_onSearch);
  }

  /// Handles both the very first load AND any pull-to-refresh.
  Future<void> _onFetchInitial(
      UserListFetchInitial event, Emitter<UserListState> emit) async {
    // 1) Capture the “old” list before we clear it.
    final previousUsers = List<User>.from(_users);

    // 2) Reset pagination & search parameters
    _skip = 0;
    _hasMore = true;
    _searchQuery = null;

    // 3) Now tell the UI we’re loading.
    //    If previousUsers.isEmpty => this is truly the very first load.
    //    If previousUsers.isNotEmpty => this is pull-to-refresh.
    emit(
      UserListLoading(
        previousUsers,
        isFirstFetch: previousUsers.isEmpty,
      ),
    );

    // 4) Clear internal buffer AFTER emitting. This ensures oldUsers is non-empty
    //    if the UI already had users showing (so that UI does not switch to full spinner).
    _users.clear();

    try {
      final paginated = await _userRepository.fetchUsers(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
      );

      // 5) Add fetched users into internal list
      _users.addAll(paginated.users);
      _hasMore = paginated.hasMore;
      _skip += paginated.users.length;

      // 6) Finally emit “loaded” with the fresh data
      emit(
        UserListLoaded(
          users: List<User>.from(_users),
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  /// Pagination: load more pages at the bottom.
  Future<void> _onFetchMore(
      UserListFetchMore event, Emitter<UserListState> emit) async {
    // If no more data or already loading, do nothing
    if (!_hasMore || state is UserListLoading) return;

    // 1) Show a “loading more” state, preserving the existing list
    emit(
      UserListLoading(
        List<User>.from(_users),
        isFirstFetch: false,
      ),
    );

    try {
      final paginated = await _userRepository.fetchUsers(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
      );

      // 2) Append newly fetched users
      _users.addAll(paginated.users);
      _hasMore = paginated.hasMore;
      _skip += paginated.users.length;

      // 3) Emit updated state
      emit(
        UserListLoaded(
          users: List<User>.from(_users),
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  /// Searches for a new query. Works like a fresh load, but with query parameter.
  Future<void> _onSearch(
      UserListSearch event, Emitter<UserListState> emit) async {
    final previousUsers = List<User>.from(_users);

    // Reset pagination, but now keep the search query
    _skip = 0;
    _hasMore = true;
    _searchQuery = event.query;

    // Emit loading with old users preserved
    emit(
      UserListLoading(
        previousUsers,
        isFirstFetch: previousUsers.isEmpty,
      ),
    );

    // Clear internal buffer AFTER emitting
    _users.clear();

    try {
      final paginated = await _userRepository.fetchUsers(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
      );

      _users.addAll(paginated.users);
      _hasMore = paginated.hasMore;
      _skip += paginated.users.length;

      emit(
        UserListLoaded(
          users: List<User>.from(_users),
          hasMore: _hasMore,
        ),
      );
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }
}

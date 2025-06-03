import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/features/user_management/domain/models/user.dart';
import 'package:nineti/features/user_management/domain/repository/user_repository.dart';
import 'user_list_event.dart';
import 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserRepository _userRepository;
  static const int _limit = 20;
  int _skip = 0;
  bool _hasMore = true;
  String? _searchQuery;
  final List<User> _users = [];

  UserListBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserListInitial()) {
    on<UserListFetchInitial>(_onFetchInitial);
    on<UserListFetchMore>(_onFetchMore);
    on<UserListSearch>(_onSearch);
  }
  Future<void> _onFetchInitial(
    UserListFetchInitial event,
    Emitter<UserListState> emit,
  ) async {
    final previousUsers = List<User>.from(_users);

    _skip = 0;
    _hasMore = true;
    _searchQuery = null;

    emit(UserListLoading(previousUsers, isFirstFetch: previousUsers.isEmpty));

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

      emit(UserListLoaded(users: List<User>.from(_users), hasMore: _hasMore));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<void> _onFetchMore(
    UserListFetchMore event,
    Emitter<UserListState> emit,
  ) async {
    if (!_hasMore || state is UserListLoading) return;

    emit(UserListLoading(List<User>.from(_users), isFirstFetch: false));

    try {
      final paginated = await _userRepository.fetchUsers(
        limit: _limit,
        skip: _skip,
        search: _searchQuery,
      );

      _users.addAll(paginated.users);
      _hasMore = paginated.hasMore;
      _skip += paginated.users.length;

      emit(UserListLoaded(users: List<User>.from(_users), hasMore: _hasMore));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  Future<void> _onSearch(
    UserListSearch event,
    Emitter<UserListState> emit,
  ) async {
    final previousUsers = List<User>.from(_users);

    _skip = 0;
    _hasMore = true;
    _searchQuery = event.query;

    emit(UserListLoading(previousUsers, isFirstFetch: previousUsers.isEmpty));

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

      emit(UserListLoaded(users: List<User>.from(_users), hasMore: _hasMore));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }
}

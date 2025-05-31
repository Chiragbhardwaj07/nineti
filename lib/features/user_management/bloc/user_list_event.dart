// lib/features/user_management/bloc/user_list_event.dart
import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger initial fetch or refresh (clears old data).
class UserListFetchInitial extends UserListEvent {
  const UserListFetchInitial();
}

/// Trigger loading next page (pagination).
class UserListFetchMore extends UserListEvent {
  const UserListFetchMore();
}

/// Trigger search with a new query (resets pagination).
class UserListSearch extends UserListEvent {
  final String query;

  const UserListSearch(this.query);

  @override
  List<Object?> get props => [query];
}

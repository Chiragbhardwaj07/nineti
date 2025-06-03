// lib/features/user_management/bloc/user_list_state.dart
import 'package:equatable/equatable.dart';
import '../domain/models/user.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}

/// Before any action.
class UserListInitial extends UserListState {
  const UserListInitial();
}

/// While fetching data (either initial load or pagination).
class UserListLoading extends UserListState {
  final List<User> oldUsers;
  final bool isFirstFetch;

  const UserListLoading(this.oldUsers, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldUsers, isFirstFetch];
}

/// When data loaded successfully.
class UserListLoaded extends UserListState {
  final List<User> users;
  final bool hasMore; // whether more pages are available

  const UserListLoaded({required this.users, required this.hasMore});

  @override
  List<Object?> get props => [users, hasMore];
}

/// When an error occurs.
class UserListError extends UserListState {
  final String message;

  const UserListError(this.message);

  @override
  List<Object?> get props => [message];
}

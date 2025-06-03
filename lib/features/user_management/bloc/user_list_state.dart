import 'package:equatable/equatable.dart';
import '../domain/models/user.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object?> get props => [];
}
class UserListInitial extends UserListState {
  const UserListInitial();
}

class UserListLoading extends UserListState {
  final List<User> oldUsers;
  final bool isFirstFetch;

  const UserListLoading(this.oldUsers, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldUsers, isFirstFetch];
}

class UserListLoaded extends UserListState {
  final List<User> users;
  final bool hasMore; 

  const UserListLoaded({required this.users, required this.hasMore});

  @override
  List<Object?> get props => [users, hasMore];
}

class UserListError extends UserListState {
  final String message;

  const UserListError(this.message);

  @override
  List<Object?> get props => [message];
}

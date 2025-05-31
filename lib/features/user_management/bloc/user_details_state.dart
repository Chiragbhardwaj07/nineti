// lib/features/user_management/bloc/user_detail_state.dart
import 'package:equatable/equatable.dart';
import '../domain/models/user.dart';
import '../domain/models/post.dart';
import '../domain/models/todo.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial, before any fetch.
class UserDetailInitial extends UserDetailState {
  const UserDetailInitial();
}

/// Loading all data (user + posts + todos).
class UserDetailLoading extends UserDetailState {
  const UserDetailLoading();
}

/// Loaded successfully: contains user info, posts list, todos list.
class UserDetailLoaded extends UserDetailState {
  final User user;
  final List<Post> posts;
  final List<Todo> todos;

  const UserDetailLoaded({
    required this.user,
    required this.posts,
    required this.todos,
  });

  @override
  List<Object?> get props => [user, posts, todos];
}

/// Error state: failed to load something.
class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

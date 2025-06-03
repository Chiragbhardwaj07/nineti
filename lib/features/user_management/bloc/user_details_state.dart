import 'package:equatable/equatable.dart';
import '../domain/models/user.dart';
import '../domain/models/post.dart';
import '../domain/models/todo.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object?> get props => [];
}

class UserDetailInitial extends UserDetailState {
  const UserDetailInitial();
}

class UserDetailLoading extends UserDetailState {
  const UserDetailLoading();
}
class UserDetailLoaded extends UserDetailState {
  final User user;
  final List<Post> remotePosts;
  final List<Post> localPosts;
  final List<Todo> todos;

  const UserDetailLoaded({
    required this.user,
    required this.remotePosts,
    this.localPosts = const [],
    required this.todos,
  });

  @override
  List<Object?> get props => [user, remotePosts, localPosts, todos];
  UserDetailLoaded copyWithAddedPost(Post newPost) {
    return UserDetailLoaded(
      user: user,
      remotePosts: remotePosts,
      localPosts: List.of(localPosts)..add(newPost),
      todos: todos,
    );
  }
}

class UserDetailError extends UserDetailState {
  final String message;
  const UserDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// lib/features/user_management/bloc/user_detail_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_details_event.dart';
import 'package:nineti/features/user_management/bloc/user_details_state.dart';
import '../domain/models/user.dart';
import '../domain/models/post.dart';
import '../domain/models/todo.dart';
import '../domain/repository/user_repository.dart';


class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository _userRepository;

  UserDetailBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserDetailInitial()) {
    on<FetchUserDetail>(_onFetchUserDetail);
    on<AddLocalPost>(_onAddLocalPost);
  }

  Future<void> _onFetchUserDetail(
      FetchUserDetail event, Emitter<UserDetailState> emit) async {
    emit(const UserDetailLoading());
    try {
      final User user = await _userRepository.fetchUserById(event.userId);
      final List<Post> remotePosts =
          await _userRepository.fetchPostsForUser(event.userId);
      final List<Todo> todos =
          await _userRepository.fetchTodosForUser(event.userId);

      emit(UserDetailLoaded(
        user: user,
        remotePosts: remotePosts,
        localPosts: const [],
        todos: todos,
      ));
    } catch (e) {
      emit(UserDetailError(e.toString()));
    }
  }

  Future<void> _onAddLocalPost(
      AddLocalPost event, Emitter<UserDetailState> emit) async {
    final currentState = state;
    if (currentState is UserDetailLoaded) {
      // Create a new state with the new post appended to localPosts
      final updatedState = currentState.copyWithAddedPost(event.post);
      emit(updatedState);
    }
    // If not loaded yet, ignore.
  }
}

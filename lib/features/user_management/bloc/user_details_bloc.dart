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
  }

  Future<void> _onFetchUserDetail(
      FetchUserDetail event, Emitter<UserDetailState> emit) async {
    emit(const UserDetailLoading());
    try {
      // 1) Fetch user info
      final User user = await _userRepository.fetchUserById(event.userId);
      // 2) Fetch posts
      final List<Post> posts =
          await _userRepository.fetchPostsForUser(event.userId);
      // 3) Fetch todos
      final List<Todo> todos =
          await _userRepository.fetchTodosForUser(event.userId);

      emit(UserDetailLoaded(user: user, posts: posts, todos: todos));
    } catch (e) {
      emit(UserDetailError(e.toString()));
    }
  }
}

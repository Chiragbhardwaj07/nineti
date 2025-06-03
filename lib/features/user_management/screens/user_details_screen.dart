// lib/features/user_management/screens/user_detail/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/features/user_management/bloc/user_details_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_details_event.dart';
import 'package:nineti/features/user_management/bloc/user_details_state.dart';
import 'package:nineti/features/user_management/domain/models/post.dart';
import 'package:nineti/features/user_management/domain/models/todo.dart';
import 'package:nineti/features/user_management/domain/models/user.dart';
import 'package:nineti/features/user_management/screens/create_post_screen.dart';
import 'package:nineti/features/user_management/widgets/post_tile.dart';
import 'package:nineti/features/user_management/widgets/todo_tile.dart';



class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserDetailBloc>().add(FetchUserDetail(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeCubit.toggleTheme(),
          ),
        ],
      ),
      body: BlocBuilder<UserDetailBloc, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserDetailError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is UserDetailLoaded) {
            return _buildDetailContent(context, state.user, state.remotePosts, state.localPosts, state.todos);
          }
          return const SizedBox.shrink();
        },
      ),
      // Floating action button to open CreatePostScreen
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    // First, get the existing UserDetailBloc
    final detailBloc = context.read<UserDetailBloc>();

    // Navigate manually, passing the bloc as a value
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: detailBloc,
          child: CreatePostScreen(userId: widget.userId),
        ),
      ),
    );
  },
  child: const Icon(Icons.add),
  tooltip: 'Create New Post',
),

    );
  }

  Widget _buildDetailContent(BuildContext context, User user, List<Post> remotePosts, List<Post> localPosts, List<Todo> todos) {
    // Combine remote + local posts (we’ll show local posts above remote ones)
    final allPosts = <Post>[...localPosts, ...remotePosts];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(user),
            const SizedBox(height: 24),
            _buildSectionTitle('Posts'),
            const SizedBox(height: 8),
            if (allPosts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No posts available.'),
              )
            else
              ...allPosts.map((p) => PostTile(post: p)).toList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Todos'),
            const SizedBox(height: 8),
            if (todos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No todos available.'),
              )
            else
              ...todos.map((t) => TodoTile(todo: t)).toList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(user.email, style: const TextStyle(fontSize: 16)),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

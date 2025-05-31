import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/features/user_management/bloc/user_list_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_list_event.dart';
import 'package:nineti/features/user_management/bloc/user_list_state.dart';
import 'package:nineti/features/user_management/widgets/user_tile.dart';
import 'package:nineti/features/user_management/widgets/wrap_indicator.dart';



class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Kick off first fetch
    context.read<UserListBloc>().add(const UserListFetchInitial());
    // Listen for bottom‐of‐list to load more
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 200.0;
    if (_scrollController.position.maxScrollExtent - _scrollController.offset <=
        threshold) {
      context.read<UserListBloc>().add(const UserListFetchMore());
    }
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<UserListBloc>();
    bloc.add(const UserListFetchInitial());
    await bloc.stream.firstWhere(
      (state) => state is UserListLoaded || state is UserListError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip:
                isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () => themeCubit.toggleTheme(),
          ),
        ],
      ),
      body: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          // ─── 1) VERY FIRST LOAD ────────────────────────────────────────────
          // If we're loading AND we have no old users, show a full-screen spinner.
          if (state is UserListLoading && state.oldUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─── 2) ERROR ─────────────────────────────────────────────────────
          if (state is UserListError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // ─── 3) DATA (Loaded or “loading more” or “pull-to-refresh”) ─────
          if (state is UserListLoaded || state is UserListLoading) {
            // Determine the current list of users to display
            final users = (state is UserListLoaded)
                ? state.users
                : (state as UserListLoading).oldUsers;

            // Check if there are more pages
            final hasMore = (state is UserListLoaded) ? state.hasMore : true;

            // If we have loaded zero users after the initial fetch, show “No users found.”
            if (users.isEmpty && state is UserListLoaded) {
              return const Center(child: Text('No users found.'));
            }

            // ─── 3a) WRAP IN WarpIndicator ──────────────────────────────────
            return WarpIndicator(
              onRefresh: _onRefresh,
              skyColor: isDarkMode ? Colors.black : Colors.blue[100]!,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: users.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < users.length) {
                    final user = users[index];
                    return UserTile(
                      name: user.fullName,
                      email: user.email,
                      avatarUrl: user.image,
                       onTap: () {
                      
                        context.push('/user/${user.id}');
                      },
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            );
          }

          // ─── 4) FALLBACK ──────────────────────────────────────────────────
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

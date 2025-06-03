import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/features/user_management/bloc/user_list_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_list_event.dart';
import 'package:nineti/features/user_management/bloc/user_list_state.dart';
import 'package:nineti/features/user_management/widgets/user_tile.dart';
import 'package:nineti/features/user_management/widgets/wrap_indicator.dart';
import 'dart:async';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;
  late final FocusNode _searchFocusNode;

  Timer? _debounce; // For debouncing search input

  @override
  void initState() {
    super.initState();

    // 1) Trigger initial load
    context.read<UserListBloc>().add(const UserListFetchInitial());

    // 2) Listen for infinite scroll
    _scrollController.addListener(_onScroll);

    // 3) Listen to changes in the search field (optional: to clear search when tapping “X”)
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode = FocusNode(canRequestFocus: false);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 200.0;
    if (_scrollController.position.maxScrollExtent - _scrollController.offset <=
        threshold) {
      context.read<UserListBloc>().add(const UserListFetchMore());
    }
  }

  /// Called when the text in the search field changes.
  /// Implements a 500 ms debounce: when the user stops typing for half a second,
  /// we dispatch a new search. If the field is empty, we revert to the full list.
  void _onSearchTextChanged() {
    final query = _searchController.text.trim();

    // Cancel any existing debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        // If the search field is cleared, reload the full list
        context.read<UserListBloc>().add(const UserListFetchInitial());
      } else {
        // Otherwise, dispatch a search event
        context.read<UserListBloc>().add(UserListSearch(query));
      }
      // After firing the event, scroll back to top so the user sees results from the beginning
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  /// For pull-to-refresh
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
        backgroundColor: isDarkMode ? Colors.black : Colors.blue.shade100,
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () => themeCubit.toggleTheme(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildSearchBar(isDarkMode),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside the TextField
          FocusScope.of(context).unfocus();
          _isSearchActive = false;
          _searchFocusNode.canRequestFocus =
              false; // Prevent focus until tapped again
        },
        child: BlocBuilder<UserListBloc, UserListState>(
          builder: (context, state) {
            // 1) FIRST LOAD (no users yet) → full-screen spinner
            if (state is UserListLoading && state.oldUsers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2) ERROR state
            if (state is UserListError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            // 3) LOADED / LOADING MORE / PULL-TO-REFRESH
            if (state is UserListLoaded || state is UserListLoading) {
              final users = (state is UserListLoaded)
                  ? state.users
                  : (state as UserListLoading).oldUsers;
              final hasMore = (state is UserListLoaded) ? state.hasMore : true;

              // If there are absolutely no users after a load
              if (users.isEmpty && state is UserListLoaded) {
                return const Center(child: Text('No users found.'));
              }

              // Wrap the ListView in your WarpIndicator for pull-to-refresh
              return WarpIndicator(
                starColorGetter: (index) => isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.blueAccent.shade100, 
                onRefresh: _onRefresh,
                skyColor: isDarkMode ? Colors.black45 : Colors.blue.shade50,
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
                          // BEFORE navigating: dismiss focus and disable future auto-focus
                          _searchFocusNode.unfocus();
                          _isSearchActive = false;
                          _searchFocusNode.canRequestFocus = false;

                          // THEN navigate
                          context.push('/user/${user.id}');
                        },
                      );
                    } else {
                      // Show a “loading more” spinner at the bottom
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              );
            }

            // 4) FALLBACK (shouldn’t really happen)
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// Builds the search TextField inside the AppBar’s bottom area.

Widget _buildSearchBar(bool isDarkMode) {
  return GestureDetector(
    onTap: () {
      // Enable focus and open keyboard when tapped
      setState(() {
        _isSearchActive = true;
        _searchFocusNode.canRequestFocus = true;
      });
      _searchFocusNode.requestFocus();
    },
    child: TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  // Clear the field
                  _searchController.clear();
    
                  // Reload full user list
                  context.read<UserListBloc>().add(const UserListFetchInitial());
    
                  // Dismiss keyboard & disable future focus until tapped
                  _searchFocusNode.unfocus();
                  setState(() {
                    _isSearchActive = false;
                    _searchFocusNode.canRequestFocus = false;
                  });
                },
              ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) {
        // Rebuild to show/hide clear button as text changes
        setState(() {});
      },
      onSubmitted: (_) {
        // When the user presses “Search” on keyboard, you might want to unfocus:
        _searchFocusNode.unfocus();
        setState(() => _isSearchActive = false);
      },
    ),
  );
}

}
 
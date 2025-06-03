import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator/loading_indicator.dart';
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

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<UserListBloc>().add(const UserListFetchInitial());
    _scrollController.addListener(_onScroll);
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

  void _onSearchTextChanged() {
    final query = _searchController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context.read<UserListBloc>().add(const UserListFetchInitial());
      } else {
        context.read<UserListBloc>().add(UserListSearch(query));
      }

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
        backgroundColor: isDarkMode ? Colors.black : Colors.blue.shade100,
        title: const Text('User List'),
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
          FocusScope.of(context).unfocus();
          _isSearchActive = false;
          _searchFocusNode.canRequestFocus = false;
        },
        child: BlocBuilder<UserListBloc, UserListState>(
          builder: (context, state) {
            if (state is UserListLoading && state.oldUsers.isEmpty) {
              return  Center(child: SizedBox(
                height: 50,
                child: LoadingIndicator(
                              indicatorType: Indicator.ballPulse,
                
                              /// Required, The loading type of the widget
                              colors: isDarkMode
                                  ? [Colors.white.withOpacity(0.8)]
                                  : [Colors.blueAccent.shade100],
                
                              /// Optional, The color collections
                              strokeWidth: 2,
                
                              /// Optional, the stroke backgroundColor
                            ),
              ),);
            }

            if (state is UserListError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is UserListLoaded || state is UserListLoading) {
              final users = (state is UserListLoaded)
                  ? state.users
                  : (state as UserListLoading).oldUsers;
              final hasMore = (state is UserListLoaded) ? state.hasMore : true;

              if (users.isEmpty && state is UserListLoaded) {
                return const Center(child: Text('No users found.'));
              }

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
                          _searchFocusNode.unfocus();
                          _isSearchActive = false;
                          _searchFocusNode.canRequestFocus = false;

                          context.push('/user/${user.id}');
                        },
                      );
                    } else {
                      return  Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child:  SizedBox(
                            height: 50,
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                            
                                /// Required, The loading type of the widget
                                colors: isDarkMode
                                    ? [Colors.white.withOpacity(0.8)]
                                    : [Colors.blueAccent.shade100],
                                            
                                /// Optional, The color collections
                                strokeWidth: 2,
                                            
                                /// Optional, the stroke backgroundColor
                              ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
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
                    _searchController.clear();

                    context.read<UserListBloc>().add(
                      const UserListFetchInitial(),
                    );

                    _searchFocusNode.unfocus();
                    setState(() {
                      _isSearchActive = false;
                      _searchFocusNode.canRequestFocus = false;
                    });
                  },
                ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) {
          setState(() {});
        },
        onSubmitted: (_) {
          _searchFocusNode.unfocus();
          setState(() => _isSearchActive = false);
        },
      ),
    );
  }
}

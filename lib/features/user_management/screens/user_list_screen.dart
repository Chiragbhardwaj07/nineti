// lib/features/user_management/screens/user_list/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/features/user_management/widgets/user_tile.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyUsers = [
      {
        'name': 'Alice Johnson',
        'email': 'alice@example.com',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'name': 'Bob Smith',
        'email': 'bob@example.com',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'name': 'Charlie Lee',
        'email': 'charlie@example.com',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
      },
    ];

    final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              themeCubit.toggleTheme();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyUsers.length,
        itemBuilder: (context, index) {
          final user = dummyUsers[index];
          return UserTile(
            name: user['name']!,
            email: user['email']!,
            avatarUrl: user['avatarUrl']!,
          );
        },
      ),
    );
  }
}

// lib/features/user_management/screens/user_list/widgets/user_tile.dart
import 'package:flutter/material.dart';

/// A small, reusable tile that displays a user’s avatar, name, and email.
class UserTile extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;

  const UserTile({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        radius: 24,
      ),
      title: Text(name),
      subtitle: Text(email),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        // TODO: Navigator.pushNamed(context, '/user/${someId}');
      },
    );
  }
}

// lib/features/user_management/screens/user_list/widgets/user_tile.dart
import 'package:flutter/material.dart';

/// A reusable tile showing a user’s avatar, name, and email.
/// Tapping it triggers the optional [onTap] callback.
class UserTile extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final VoidCallback? onTap;

  const UserTile({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.onTap,
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
      onTap: onTap, // <-- this is where the callback gets invoked
    );
  }
}

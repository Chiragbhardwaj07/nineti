import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User $userId")),
      body: Center(child: Text("Details for user ID: $userId")),
    );
  }
}

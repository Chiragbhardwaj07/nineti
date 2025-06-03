// lib/features/user_management/screens/create_post/create_post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_details_bloc.dart';
import 'package:nineti/features/user_management/bloc/user_details_event.dart';
import 'package:nineti/features/user_management/domain/models/post.dart';
class CreatePostScreen extends StatefulWidget {
  final int userId;
  const CreatePostScreen({super.key, required this.userId});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPost = Post(
        // Assign a negative or timestamp ID to avoid collision with remote IDs
        id: DateTime.now().millisecondsSinceEpoch,
        userId: widget.userId,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );

      // Dispatch AddLocalPost to the UserDetailBloc
      context.read<UserDetailBloc>().add(AddLocalPost(newPost));

      // Pop back to the detail screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Body is required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  child: const Text('Save Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

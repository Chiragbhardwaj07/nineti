import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/app/app_theme_cubit.dart';
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
        id: DateTime.now().millisecondsSinceEpoch,
        userId: widget.userId,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      context.read<UserDetailBloc>().add(AddLocalPost(newPost));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
     final themeCubit = context.read<ThemeCubit>();
    final isDarkMode = context.watch<ThemeCubit>().state == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.blue.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.black : Colors.blue.shade100,
                  ),
                  onPressed: _onSubmit,
                  child:  Text('Save Post',
                    style: TextStyle(color: isDarkMode?Colors.white:Colors.black45, fontSize: 16),)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

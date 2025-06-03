import 'package:flutter/material.dart';
import 'package:nineti/features/user_management/domain/models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        todo.completed ? Icons.check_circle : Icons.circle_outlined,
        color: todo.completed ? Colors.green : Colors.grey,
      ),
      title: Text(
        todo.todo,
        style: TextStyle(
          fontSize: 14,
          decoration:
              todo.completed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

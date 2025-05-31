// lib/features/user_management/domain/models/todo.dart
import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final int userId;
  final String todo;
  final bool completed;

  const Todo({
    required this.id,
    required this.userId,
    required this.todo,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      userId: json['userId'] as int,
      todo: json['todo'] as String,
      completed: json['completed'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, userId, todo, completed];
}

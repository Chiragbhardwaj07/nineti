import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 2)
class Todo extends Equatable {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String todo;

  @HiveField(3)
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

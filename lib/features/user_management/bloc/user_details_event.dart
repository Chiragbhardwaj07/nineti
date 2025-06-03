// lib/features/user_management/bloc/user_detail_event.dart
import 'package:equatable/equatable.dart';
import '../domain/models/post.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserDetail extends UserDetailEvent {
  final int userId;
  const FetchUserDetail(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// New event: add a post locally (title + body).
class AddLocalPost extends UserDetailEvent {
  final Post post;
  const AddLocalPost(this.post);

  @override
  List<Object?> get props => [post];
}

// lib/features/user_management/bloc/user_detail_event.dart
import 'package:equatable/equatable.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger fetching full details for a user: user info, posts, todos.
class FetchUserDetail extends UserDetailEvent {
  final int userId;
  const FetchUserDetail(this.userId);

  @override
  List<Object?> get props => [userId];
}

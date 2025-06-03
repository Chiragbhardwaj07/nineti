import 'package:equatable/equatable.dart';

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

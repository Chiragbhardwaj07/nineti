import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object?> get props => [];
}

class UserListFetchInitial extends UserListEvent {
  const UserListFetchInitial();
}

class UserListFetchMore extends UserListEvent {
  const UserListFetchMore();
}

class UserListSearch extends UserListEvent {
  final String query;

  const UserListSearch(this.query);

  @override
  List<Object?> get props => [query];
}

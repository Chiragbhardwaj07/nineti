import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/features/user_management/bloc/user_list_bloc.dart';
import 'package:nineti/features/user_management/domain/repository/user_repository.dart';

class AppBlocProviders {
  static List<BlocProvider> get allBlocProviders => [
    BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    BlocProvider<UserListBloc>(
      create: (_) => UserListBloc(userRepository: UserRepository()),
    ),
  ];
}

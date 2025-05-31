import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nineti/app/app_theme_cubit.dart';

class AppBlocProviders {
  static List<BlocProvider> get allBlocProviders => [
    BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
    // BlocProvider<AuthenticationBloc>(
    //   create: (context) => AuthenticationBloc(AuthRepository()),
    // ),

    // Add more BlocProviders as you add more features
  ];
}

import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocProviders {
  static List<BlocProvider> get allBlocProviders => [
        // BlocProvider<AuthenticationBloc>(
        //   create: (context) => AuthenticationBloc(AuthRepository()),
        // ),

        // Add more BlocProviders as you add more features
      ];
}
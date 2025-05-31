import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:nineti/app/app_bloc_provider.dart';
import 'package:nineti/app/app_router.dart';
import 'package:nineti/app/app_themes.dart';


void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.allBlocProviders,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'User Manager',
        darkTheme: AppTheme.darkTheme,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        builder: (context, child) {
          EasyLoading.instance
            ..indicatorType = EasyLoadingIndicatorType.threeBounce
            ..loadingStyle = EasyLoadingStyle.custom
            ..indicatorSize = 40.0
            ..textColor = Colors.transparent
            ..backgroundColor = Colors.transparent
            ..indicatorColor = Colors.blueAccent.shade100
            ..maskType = EasyLoadingMaskType.black
            ..animationStyle = EasyLoadingAnimationStyle.opacity
            ..userInteractions = false;
          return FlutterEasyLoading(child: child);
        },
        routerConfig: routes,
      ),
    );
  }
}

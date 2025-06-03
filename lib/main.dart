import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nineti/app/app_bloc_provider.dart';
import 'package:nineti/app/app_theme_cubit.dart';
import 'package:nineti/app/app_themes.dart';
import 'package:path_provider/path_provider.dart';
import 'app/app_router.dart';
import 'features/user_management/domain/models/user.dart';
import 'features/user_management/domain/models/post.dart';
import 'features/user_management/domain/models/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(PostAdapter());
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<User>('usersBox');
  await Hive.openBox<List>('postsBox'); 
  await Hive.openBox<List>('todosBox'); 

  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppBlocProviders.allBlocProviders,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'User Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: routes,
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
          );
        },
      ),
    );
  }
}

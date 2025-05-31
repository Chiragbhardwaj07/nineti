import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nineti/features/user_management/bloc/user_details_bloc.dart';
import 'package:nineti/features/user_management/domain/repository/user_repository.dart';
import 'package:nineti/features/user_management/index.dart';


CustomTransitionPage<T> customTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.linear;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final GoRouter routes = GoRouter(
  initialLocation: '/',
  routes: <GoRoute>[
    // Home screen: User list
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const UserListScreen();
      },
      pageBuilder: (context, state) =>
          customTransition(context: context, state: state, child: const UserListScreen()),
    ),

    // User detail screen
    GoRoute(
      path: '/user/:id',
      pageBuilder: (context, state) {
        final userId = int.parse(state.pathParameters['id']!);
        return CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider<UserDetailBloc>(
            create: (_) => UserDetailBloc(userRepository: UserRepository()),
            child: UserDetailScreen(userId: userId),
          ),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.linear;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    ),

    // Create post screen
    GoRoute(
      path: '/create_post',
      builder: (BuildContext context, GoRouterState state) {
        return const CreatePostScreen();
      },
      pageBuilder: (context, state) =>
          customTransition(context: context, state: state, child: const CreatePostScreen()),
    ),
  ],
);
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/features/lists/screens/create_list_screen.dart';
import 'package:todoapp/features/lists/screens/lists_screen.dart';
import 'package:todoapp/features/lists/screens/share_screen.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/todos/screens/todos_screen.dart';
import '../../features/todos/screens/create_todo_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/lists';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/lists',
        name: 'lists',
        builder: (context, state) => const ListsScreen(),
      ),
      GoRoute(
        path: '/lists/create',
        name: 'createList',
        builder: (context, state) => const CreateListScreen(),
      ),
      GoRoute(
        path: '/lists/:id/share',
        name: 'share',
        builder: (context, state) {
          final listId = state.pathParameters['id']!;
          return ShareScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/lists/:id/todos',
        name: 'todos',
        builder: (context, state) {
          final listId = state.pathParameters['id']!;
          return TodosScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/todos/create',
        name: 'createTodo',
        builder: (context, state) => const CreateTodoScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page non trouvée: ${state.matchedLocation}')),
    ),
  );
});

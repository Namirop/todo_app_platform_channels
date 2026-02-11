import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/domain/entities/list.dart';
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
        path: '/lists/:listId/share',
        name: 'share',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return ShareScreen(listId: listId);
        },
      ),
      GoRoute(
        path: '/lists/:listId/todos',
        name: 'todos',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          final list = state.extra as ListEntity;
          return TodosScreen(listId: listId, list: list);
        },
      ),
      GoRoute(
        path: '/todos/:listId/create',
        name: 'createTodo',
        builder: (context, state) {
          final listId = state.pathParameters['listId']!;
          return CreateTodoScreen(listId: listId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page non trouvée: ${state.matchedLocation}')),
    ),
  );
});

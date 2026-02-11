import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/repositories/todos_repository.dart';
import '../state/todos_state.dart';

final todosProvider = StateNotifierProvider<TodosNotifier, TodosState>((ref) {
  return TodosNotifier(ref.watch(todosRepositoryProvider));
});

class TodosNotifier extends StateNotifier<TodosState> {
  final TodosRepository _todosRepository;
  StreamSubscription<List<TodoEntity>>? _subscription;

  TodosNotifier(this._todosRepository) : super(const TodosState());

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void watchTodos({String? listId}) {
    _subscription?.cancel();

    state = state.copyWith(isLoading: true, clearError: true);

    _subscription = _todosRepository.watchTodos(listId: listId).listen(
      (todos) {
        state = state.copyWith(todos: todos, isLoading: false);
      },
      onError: (error, stackTrace) {
        if (error is AppException) {
          state = state.copyWith(isLoading: false, error: error.message);
        } else {
          debugPrint('watchTodos error: $error\n$stackTrace');
          state = state.copyWith(
            isLoading: false,
            error: 'Une erreur est survenue',
          );
        }
      },
    );
  }

  Future<void> fetchTodos(String listId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final todos = await _todosRepository.getTodos(listId);
      state = state.copyWith(todos: todos, isLoading: false);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stackTrace) {
      debugPrint('fetchTodos error: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: 'Une erreur est survenue',
      );
    }
  }

  Future<void> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 0,
    required String listId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final todo = await _todosRepository.createTodo(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        listId: listId,
      );

      state = state.copyWith(
        todos: [...state.todos, todo],
        isSubmitting: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(error: e.message, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Une erreur est survenue',
        isSubmitting: false,
      );
    }
  }

  Future<bool> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
  }) async {
    try {
      final updatedTodo = await _todosRepository.updateTodo(
        id,
        title: title,
        description: description,
        completed: completed,
        dueDate: dueDate,
        priority: priority,
      );

      state = state.copyWith(
        todos: state.todos.map((t) => t.id == id ? updatedTodo : t).toList(),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('updateTodo error: $e\n$stackTrace');
      state = state.copyWith(error: 'Une erreur est survenue');
      return false;
    }
  }

  Future<bool> toggleCompleted(String id, bool completed) async {
    // Optimistic update
    final originalTodos = state.todos;
    state = state.copyWith(
      todos: state.todos
          .map((t) => t.id == id ? t.copyWith(completed: completed) : t)
          .toList(),
    );

    final success = await updateTodo(id, completed: completed);
    if (!success) {
      // Revert on failure
      state = state.copyWith(todos: originalTodos);
    }
    return success;
  }

  Future<bool> deleteTodo(String id) async {
    try {
      await _todosRepository.deleteTodo(id);
      state = state.copyWith(
        todos: state.todos.where((t) => t.id != id).toList(),
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (e, stackTrace) {
      debugPrint('deleteTodo error: $e\n$stackTrace');
      state = state.copyWith(error: 'Une erreur est survenue');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

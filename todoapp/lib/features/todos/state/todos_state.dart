import '../../../domain/entities/todo.dart';

class TodosState {
  final List<TodoEntity> todos;
  final bool isLoading;
  final String? error;

  const TodosState({this.todos = const [], this.isLoading = false, this.error});

  TodosState copyWith({
    List<TodoEntity>? todos,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Filtered views
  List<TodoEntity> get completedTodos =>
      todos.where((t) => t.completed).toList();
  List<TodoEntity> get pendingTodos =>
      todos.where((t) => !t.completed).toList();
  List<TodoEntity> get overdueTodos => todos.where((t) => t.isOverdue).toList();
  List<TodoEntity> get dueTodayTodos =>
      todos.where((t) => t.isDueToday).toList();

  List<TodoEntity> byPriority(int priority) =>
      todos.where((t) => t.priority == priority).toList();

  List<TodoEntity> byList(String listId) =>
      todos.where((t) => t.listId == listId).toList();
}

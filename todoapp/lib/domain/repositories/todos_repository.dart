import '../entities/todo.dart';

abstract class TodosRepository {
  Stream<List<TodoEntity>> watchTodos({String? listId});
  Future<List<TodoEntity>> getTodos(String listId);
  Future<TodoEntity> getTodoById(String id);
  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 0,
    String? listId,
  });
  Future<TodoEntity> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
  });
  Future<void> deleteTodo(String id);
  Future<void> refreshTodos({String? listId});
}

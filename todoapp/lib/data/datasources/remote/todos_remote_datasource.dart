import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/services/api_service.dart';
import '../../models/todo_model.dart';

abstract class TodosRemoteDataSource {
  Future<List<TodoModel>> getTodos(String listId);
  Future<TodoModel> getTodoById(String id);
  Future<TodoModel> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 0,
    String listId,
  });
  Future<TodoModel> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
  });
  Future<void> deleteTodo(String id);
}

class TodosRemoteDataSourceImpl implements TodosRemoteDataSource {
  final ApiService _apiService;

  TodosRemoteDataSourceImpl(this._apiService);

  Never _handleDioError(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data['error'] as String?;

    switch (statusCode) {
      case 400:
        throw ValidationException(message: errorMessage ?? 'Données invalides');
      case 403:
        throw ForbiddenException(
          message: errorMessage ?? 'Action non autorisée',
        );
      case 404:
        throw NotFoundException(
          message: errorMessage ?? 'Ressource introuvable',
        );
      case 503:
        throw ServerException(
          message: 'Le serveur rencontre un problème, réessayez plus tard',
          statusCode: statusCode,
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw NetworkException(message: 'La connexion a expiré');
        }
        if (e.type == DioExceptionType.connectionError) {
          throw NetworkException(message: 'Impossible de contacter le serveur');
        }
        throw ServerException(
          message: errorMessage ?? defaultMessage,
          statusCode: statusCode,
        );
    }
  }

  @override
  Future<List<TodoModel>> getTodos(String listId) async {
    try {
      final response = await _apiService.get('${ApiConstants.todos}/$listId');

      return (response.data as List)
          .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e, 'Erreur lors du chargement des tâches');
    }
  }

  @override
  Future<TodoModel> getTodoById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.todos}/$id');
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e, 'Erreur lors du chargement de la tâche');
    }
  }

  @override
  Future<TodoModel> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 0,
    String? listId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.todos,
        data: {
          'title': title,
          if (description != null) 'description': description,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
          'priority': priority,
          if (listId != null) 'listId': listId,
        },
      );

      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e, 'Erreur lors de la création');
    }
  }

  @override
  Future<TodoModel> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
  }) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.todos}/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (completed != null) 'completed': completed,
          if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
          if (priority != null) 'priority': priority,
        },
      );

      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleDioError(e, 'Erreur lors de la mise à jour');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await _apiService.delete('${ApiConstants.todos}/$id');
    } on DioException catch (e) {
      _handleDioError(e, 'Erreur lors de la suppression');
    }
  }
}

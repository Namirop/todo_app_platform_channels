import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todos_repository.dart';
import '../datasources/local/todos_local_datasource.dart';
import '../datasources/remote/todos_remote_datasource.dart';

class TodosRepositoryImpl implements TodosRepository {
  final TodosRemoteDataSource _remoteDataSource;
  final TodosLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TodosRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Stream<List<TodoEntity>> watchTodos({String? listId}) async* {
    final cached = _localDataSource.getTodos(listId: listId);
    if (cached.isNotEmpty) {
      yield cached.map((m) => m.toEntity()).toList();
    }

    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getTodos(listId!);
        await _localDataSource.cacheTodos(remote, listId: listId);
        yield remote.map((m) => m.toEntity()).toList();
      } catch (e, stackTrace) {
        debugPrint('watchTodos fetch error: $e\n$stackTrace');
        if (cached.isEmpty) rethrow;
      }
    }

    yield* _localDataSource
        .watchTodos(listId: listId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<TodoEntity>> getTodos(String listId) async {
    final cached = _localDataSource.getTodos(listId: listId);

    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getTodos(listId);
        await _localDataSource.cacheTodos(remote, listId: listId);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e, stackTrace) {
        debugPrint('getTodos fetch error: $e\n$stackTrace');
        if (cached.isEmpty) rethrow;
        return cached.map((m) => m.toEntity()).toList();
      }
    }

    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TodoEntity> getTodoById(String id) async {
    final cached = _localDataSource.getTodo(id);

    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getTodoById(id);
        await _localDataSource.cacheTodo(remote);
        return remote.toEntity();
      } catch (e, stackTrace) {
        debugPrint('getTodoById fetch error: $e\n$stackTrace');
        if (cached == null) rethrow;
        return cached.toEntity();
      }
    }

    if (cached == null) {
      throw CacheException(message: 'Todo non trouvé');
    }

    return cached.toEntity();
  }

  @override
  Future<TodoEntity> createTodo({
    required String title,
    String? description,
    DateTime? dueDate,
    int priority = 0,
    required String listId,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Connexion internet requise');
    }

    final remote = await _remoteDataSource.createTodo(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      listId: listId,
    );
    await _localDataSource.cacheTodo(remote);
    return remote.toEntity();
  }

  @override
  Future<TodoEntity> updateTodo(
    String id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Connexion internet requise');
    }

    final remote = await _remoteDataSource.updateTodo(
      id,
      title: title,
      description: description,
      completed: completed,
      dueDate: dueDate,
      priority: priority,
    );
    await _localDataSource.cacheTodo(remote);
    return remote.toEntity();
  }

  @override
  Future<void> deleteTodo(String id) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Connexion internet requise');
    }

    await _remoteDataSource.deleteTodo(id);
    await _localDataSource.deleteTodo(id);
  }
}

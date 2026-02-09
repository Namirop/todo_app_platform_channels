import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/services/cache_service.dart';
import '../../models/todo_model.dart';

abstract class TodosLocalDataSource {
  Future<void> cacheTodos(List<TodoModel> todos, {String? listId});
  List<TodoModel> getTodos({String? listId});
  Future<void> cacheTodo(TodoModel todo);
  TodoModel? getTodo(String id);
  Future<void> deleteTodo(String id);
  Future<void> clearTodos({String? listId});
  Stream<List<TodoModel>> watchTodos({String? listId});
}

class TodosLocalDataSourceImpl implements TodosLocalDataSource {
  final CacheService _cacheService;
  static const String _allTodosKey = 'all_todos';

  TodosLocalDataSourceImpl(this._cacheService);

  String _getKeyForList(String? listId) =>
      listId != null ? 'list_$listId' : _allTodosKey;

  @override
  Future<void> cacheTodos(List<TodoModel> todos, {String? listId}) async {
    try {
      final entries = <String, Map<String, dynamic>>{};

      for (final todo in todos) {
        entries[todo.id] = todo.toJson();
      }
      await _cacheService.putAll(CacheService.todosBoxName, entries);

      final key = _getKeyForList(listId);
      await _cacheService.put(CacheService.todosBoxName, key, {
        'ids': todos.map((t) => t.id).toList(),
      });
    } catch (e) {
      throw CacheException(message: 'Failed to cache todos: $e');
    }
  }

  @override
  List<TodoModel> getTodos({String? listId}) {
    try {
      final key = _getKeyForList(listId);
      final idsData = _cacheService.get(CacheService.todosBoxName, key);

      if (idsData == null) return [];

      final ids = (idsData['ids'] as List).cast<String>();
      final todos = <TodoModel>[];

      for (final id in ids) {
        final todoJson = _cacheService.get(CacheService.todosBoxName, id);
        if (todoJson != null) {
          todos.add(TodoModel.fromJson(todoJson));
        }
      }

      return todos;
    } catch (e, stackTrace) {
      debugPrint('getTodos error: $e\n$stackTrace');
      return [];
    }
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    try {
      await _cacheService.put(
        CacheService.todosBoxName,
        todo.id,
        todo.toJson(),
      );

      // Update the all_todos list if exists
      final idsData = _cacheService.get(
        CacheService.todosBoxName,
        _allTodosKey,
      );
      if (idsData != null) {
        final ids = (idsData['ids'] as List).cast<String>();
        if (!ids.contains(todo.id)) {
          ids.insert(0, todo.id);
          await _cacheService.put(CacheService.todosBoxName, _allTodosKey, {
            'ids': ids,
          });
        }
      }

      // Also update the list-specific cache if exists
      final listKey = _getKeyForList(todo.listId);
      final listIdsData = _cacheService.get(CacheService.todosBoxName, listKey);
      if (listIdsData != null) {
        final listIds = (listIdsData['ids'] as List).cast<String>();
        if (!listIds.contains(todo.id)) {
          listIds.insert(0, todo.id);
          await _cacheService.put(CacheService.todosBoxName, listKey, {
            'ids': listIds,
          });
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache todo: $e');
    }
  }

  @override
  TodoModel? getTodo(String id) {
    try {
      final json = _cacheService.get(CacheService.todosBoxName, id);
      return json != null ? TodoModel.fromJson(json) : null;
    } catch (e, stackTrace) {
      debugPrint('getTodo error: $e\n$stackTrace');
      return null;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      final todo = getTodo(id);

      await _cacheService.delete(CacheService.todosBoxName, id);

      final idsData = _cacheService.get(
        CacheService.todosBoxName,
        _allTodosKey,
      );
      if (idsData != null) {
        final ids = (idsData['ids'] as List).cast<String>();
        ids.remove(id);
        await _cacheService.put(CacheService.todosBoxName, _allTodosKey, {
          'ids': ids,
        });
      }

      if (todo != null) {
        final listKey = _getKeyForList(todo.listId);
        final listIdsData = _cacheService.get(
          CacheService.todosBoxName,
          listKey,
        );
        if (listIdsData != null) {
          final listIds = (listIdsData['ids'] as List).cast<String>();
          listIds.remove(id);
          await _cacheService.put(CacheService.todosBoxName, listKey, {
            'ids': listIds,
          });
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete todo from cache: $e');
    }
  }

  @override
  Future<void> clearTodos({String? listId}) async {
    try {
      if (listId != null) {
        final key = _getKeyForList(listId);
        await _cacheService.delete(CacheService.todosBoxName, key);
      } else {
        await _cacheService.clearBox(CacheService.todosBoxName);
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear todos cache: $e');
    }
  }

  @override
  Stream<List<TodoModel>> watchTodos({String? listId}) {
    return _cacheService.watch(CacheService.todosBoxName).map((_) {
      return getTodos(listId: listId);
    });
  }
}

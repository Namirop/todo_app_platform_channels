import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/services/cache_service.dart';
import '../../models/list_model.dart';

abstract class ListsLocalDataSource {
  Future<void> cacheLists(
    List<ListModel> ownedLists,
    List<ListModel> sharedLists,
  );
  (List<ListModel> ownedLists, List<ListModel> sharedLists) getLists();
  Future<void> cacheList(ListModel list);
  ListModel? getList(String id);
  Future<void> deleteList(String id);
  Future<void> clearLists();
  Stream<(List<ListModel> ownedLists, List<ListModel> sharedLists)>
  watchLists();
}

class ListsLocalDataSourceImpl implements ListsLocalDataSource {
  final CacheService _cacheService;
  static const String _allListsKey = 'all_lists';

  ListsLocalDataSourceImpl(this._cacheService);

  @override
  Future<void> cacheLists(
    List<ListModel> ownedLists,
    List<ListModel> sharedLists,
  ) async {
    try {
      await _cacheService.put(CacheService.listsBoxName, 'owned_lists', {
        'lists': ownedLists.map((l) => l.toJson()).toList(),
      });

      await _cacheService.put(CacheService.listsBoxName, 'shared_lists', {
        'lists': sharedLists.map((l) => l.toJson()).toList(),
      });
    } catch (e) {
      throw CacheException(message: 'Failed to cache lists: $e');
    }
  }

  @override
  (List<ListModel> ownedLists, List<ListModel> sharedLists) getLists() {
    try {
      final ownedData = _cacheService.get(
        CacheService.listsBoxName,
        'owned_lists',
      );
      final sharedData = _cacheService.get(
        CacheService.listsBoxName,
        'shared_lists',
      );

      // Cast pattern from hive : .map((json) => Model.fromJson(Map<String, dynamic>.from(json as Map)))
      final owned = ownedData != null
          ? (ownedData['lists'] as List)
                .map(
                  (json) => ListModel.fromJson(
                    Map<String, dynamic>.from(json as Map),
                  ),
                )
                .toList()
          : <ListModel>[];

      final shared = sharedData != null
          ? (sharedData['lists'] as List)
                .map(
                  (json) => ListModel.fromJson(
                    Map<String, dynamic>.from(json as Map),
                  ),
                )
                .toList()
          : <ListModel>[];

      return (owned, shared);
    } catch (e, stackTrace) {
      debugPrint('getLists error: $e\n$stackTrace');
      return (<ListModel>[], <ListModel>[]);
    }
  }

  @override
  Future<void> cacheList(ListModel list) async {
    try {
      await _cacheService.put(
        CacheService.listsBoxName,
        list.id,
        list.toJson(),
      );

      final idsData = _cacheService.get(
        CacheService.listsBoxName,
        _allListsKey,
      );
      if (idsData != null) {
        final ids = (idsData['ids'] as List).cast<String>();
        if (!ids.contains(list.id)) {
          ids.insert(0, list.id);
          await _cacheService.put(CacheService.listsBoxName, _allListsKey, {
            'ids': ids,
          });
        }
      } else {
        await _cacheService.put(CacheService.listsBoxName, _allListsKey, {
          'ids': [list.id],
        });
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache list: $e');
    }
  }

  @override
  ListModel? getList(String id) {
    try {
      final json = _cacheService.get(CacheService.listsBoxName, id);
      return json != null ? ListModel.fromJson(json) : null;
    } catch (e, stackTrace) {
      debugPrint('getList error: $e\n$stackTrace');
      return null;
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _cacheService.delete(CacheService.listsBoxName, id);

      final idsData = _cacheService.get(
        CacheService.listsBoxName,
        _allListsKey,
      );
      if (idsData != null) {
        final ids = (idsData['ids'] as List).cast<String>();
        ids.remove(id);
        await _cacheService.put(CacheService.listsBoxName, _allListsKey, {
          'ids': ids,
        });
      }
    } catch (e) {
      throw CacheException(message: 'Failed to delete list from cache: $e');
    }
  }

  @override
  Future<void> clearLists() async {
    try {
      await _cacheService.clearBox(CacheService.listsBoxName);
    } catch (e) {
      throw CacheException(message: 'Failed to clear lists cache: $e');
    }
  }

  @override
  Stream<(List<ListModel> ownedLists, List<ListModel> sharedLists)>
  watchLists() {
    return _cacheService.watch(CacheService.listsBoxName).map((_) {
      return getLists();
    });
  }
}

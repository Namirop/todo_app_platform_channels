import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:todoapp/features/lists/models/share_result.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/list_share.dart';
import '../../domain/entities/list.dart';
import '../../domain/repositories/lists_repository.dart';
import '../datasources/local/lists_local_datasource.dart';
import '../datasources/remote/lists_remote_datasource.dart';
import '../models/list_model.dart';

class ListsRepositoryImpl implements ListsRepository {
  final ListsRemoteDataSource _remoteDataSource;
  final ListsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  ListsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Stream<(List<ListEntity> ownedLists, List<ListEntity> sharedLists)>
  watchLists() async* {
    final (cachedOwned, cachedShared) = _localDataSource.getLists();
    if (cachedOwned.isNotEmpty || cachedShared.isNotEmpty) {
      yield (
        cachedOwned.map((m) => m.toEntity()).toList(),
        cachedShared.map((m) => m.toEntity()).toList(),
      );
    }

    if (await _networkInfo.isConnected) {
      try {
        final (remoteOwned, remoteShared) = await _remoteDataSource.getLists();
        await _localDataSource.cacheLists(remoteOwned, remoteShared);
        yield (
          remoteOwned.map((m) => m.toEntity()).toList(),
          remoteShared.map((m) => m.toEntity()).toList(),
        );
      } catch (e, stackTrace) {
        debugPrint('watchLists fetch error: $e\n$stackTrace');
        if (cachedOwned.isEmpty && cachedShared.isEmpty) rethrow;
      }
    }

    yield* _localDataSource.watchLists().map(
      ((List<ListModel>, List<ListModel>) models) => (
        models.$1.map((m) => m.toEntity()).toList(),
        models.$2.map((m) => m.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<(List<ListEntity> ownedLists, List<ListEntity> sharedLists)>
  getLists() async {
    final (cachedOwned, cachedShared) = _localDataSource.getLists();

    if (await _networkInfo.isConnected) {
      try {
        final (remoteOwnedLists, remoteSharedLists) = await _remoteDataSource
            .getLists();
        await _localDataSource.cacheLists(remoteOwnedLists, remoteSharedLists);

        return (
          remoteOwnedLists.map((m) => m.toEntity()).toList(),
          remoteSharedLists.map((m) => m.toEntity()).toList(),
        );
      } catch (e, stackTrace) {
        debugPrint('getLists fetch error: $e\n$stackTrace');
        if (cachedOwned.isEmpty && cachedShared.isEmpty) rethrow;

        return (
          cachedOwned.map((m) => m.toEntity()).toList(),
          cachedShared.map((m) => m.toEntity()).toList(),
        );
      }
    }

    return (
      cachedOwned.map((m) => m.toEntity()).toList(),
      cachedShared.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<ListEntity> getListById(String id) async {
    final cached = _localDataSource.getList(id);

    if (await _networkInfo.isConnected) {
      try {
        final remote = await _remoteDataSource.getListById(id);
        await _localDataSource.cacheList(remote);
        return remote.toEntity();
      } catch (e, stackTrace) {
        debugPrint('getListById fetch error: $e\n$stackTrace');
        if (cached == null) rethrow;
        return cached.toEntity();
      }
    }

    if (cached == null) {
      throw CacheException(message: 'Liste non trouvée');
    }

    return cached.toEntity();
  }

  @override
  Future<ListEntity> createList(String name) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final remote = await _remoteDataSource.createList(name);
    await _localDataSource.cacheList(remote);
    return remote.toEntity();
  }

  @override
  Future<ListEntity> updateList(String id, {String? name}) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final remote = await _remoteDataSource.updateList(id, name: name);
    await _localDataSource.cacheList(remote);
    return remote.toEntity();
  }

  @override
  Future<void> deleteList(String id) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    await _remoteDataSource.deleteList(id);
    await _localDataSource.deleteList(id);
  }

  @override
  Future<void> refreshLists() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final (remoteOwned, remoteShared) = await _remoteDataSource.getLists();
    await _localDataSource.cacheLists(remoteOwned, remoteShared);
  }

  @override
  Future<ShareResult> shareList(
    String listId,
    List<Map<String, String>> shares,
  ) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final remote = await _remoteDataSource.shareList(listId, shares);
    return ShareResult(
      successCount: remote['successCount'],
      failures:
          (remote['failures'] as List?)
              ?.map((f) => ShareFailure(name: f['name'], error: f['error']))
              .toList() ??
          [],
    );
  }

  @override
  Future<void> removeShare(String listId) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    await _remoteDataSource.removeShare(listId);
  }

  @override
  Future<List<ListShare>> getListShares(String listId) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final remote = await _remoteDataSource.getListShares(listId);
    return remote.map((m) => m.toEntity()).toList();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/storage_service.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getCachedUser();
  Future<void> clearUser();
  Stream<UserModel?> watchUser();
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final CacheService _cacheService;
  final StorageService _storageService;
  static const String _userKey = 'current_user';

  AuthLocalDataSourceImpl(this._cacheService, this._storageService);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _cacheService.put(
        CacheService.userBoxName,
        _userKey,
        user.toJson(),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  UserModel? getCachedUser() {
    try {
      final json = _cacheService.get(CacheService.userBoxName, _userKey);
      return json != null ? UserModel.fromJson(json) : null;
    } catch (e, stackTrace) {
      debugPrint('getCachedUser error: $e\n$stackTrace');
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _cacheService.delete(CacheService.userBoxName, _userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear user cache: $e');
    }
  }

  @override
  Stream<UserModel?> watchUser() {
    return _cacheService.watch(CacheService.userBoxName, key: _userKey).map((
      event,
    ) {
      if (event.deleted || event.value == null) return null;
      return UserModel.fromJson(Map<String, dynamic>.from(event.value));
    });
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> clearTokens() async {
    await _storageService.clearTokens();
  }

  @override
  Future<bool> hasTokens() async {
    return _storageService.hasTokens();
  }
}

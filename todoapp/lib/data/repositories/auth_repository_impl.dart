import 'package:flutter/foundation.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<UserEntity> login(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final response = await _remoteDataSource.login(email, password);

    await _localDataSource.saveTokens(
      response.accessToken,
      response.refreshToken,
    );
    await _localDataSource.cacheUser(response.user);
    return response.user.toEntity();
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String? name,
  ) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }

    final response = await _remoteDataSource.register(email, password, name);
    await _localDataSource.saveTokens(
      response.accessToken,
      response.refreshToken,
    );
    await _localDataSource.cacheUser(response.user);
    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearTokens();
    await _localDataSource.clearUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final cachedUser = _localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser.toEntity();
    }

    if (await _networkInfo.isConnected && await _localDataSource.hasTokens()) {
      try {
        final user = await _remoteDataSource.getCurrentUser();
        await _localDataSource.cacheUser(user);
        return user.toEntity();
      } catch (e, stackTrace) {
        debugPrint('getCurrentUser error: $e\n$stackTrace');
        return null;
      }
    }

    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.hasTokens();
  }

  @override
  Stream<UserEntity?> watchCurrentUser() {
    return _localDataSource.watchUser().map((model) => model?.toEntity());
  }
}

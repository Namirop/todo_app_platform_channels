import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todoapp/data/datasources/remote/users_remote_datasource.dart';
import 'package:todoapp/data/repositories/users_repository_impl.dart';
import 'package:todoapp/domain/repositories/users_repository.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/lists_local_datasource.dart';
import '../../data/datasources/local/todos_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/lists_remote_datasource.dart';
import '../../data/datasources/remote/todos_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/lists_repository_impl.dart';
import '../../data/repositories/todos_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/lists_repository.dart';
import '../../domain/repositories/todos_repository.dart';
import '../network/network_info.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/storage_service.dart';

// Core services
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

// Remote datasources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});

final todosRemoteDataSourceProvider = Provider<TodosRemoteDataSource>((ref) {
  return TodosRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});

final listsRemoteDataSourceProvider = Provider<ListsRemoteDataSource>((ref) {
  return ListsRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});
final usersRemoteDataSourceProvider = Provider<UsersRemoteDataSource>((ref) {
  return UsersRemoteDataSourceImpl(ref.watch(apiServiceProvider));
});

// Local datasources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(
    ref.watch(cacheServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

final todosLocalDataSourceProvider = Provider<TodosLocalDataSource>((ref) {
  return TodosLocalDataSourceImpl(ref.watch(cacheServiceProvider));
});

final listsLocalDataSourceProvider = Provider<ListsLocalDataSource>((ref) {
  return ListsLocalDataSourceImpl(ref.watch(cacheServiceProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepositoryImpl(
    ref.watch(todosRemoteDataSourceProvider),
    ref.watch(todosLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final listsRepositoryProvider = Provider<ListsRepository>((ref) {
  return ListsRepositoryImpl(
    ref.watch(listsRemoteDataSourceProvider),
    ref.watch(listsLocalDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(
    ref.watch(usersRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

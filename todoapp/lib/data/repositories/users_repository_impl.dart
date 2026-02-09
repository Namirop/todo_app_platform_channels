import 'package:todoapp/core/errors/exceptions.dart';
import 'package:todoapp/core/network/network_info.dart';
import 'package:todoapp/data/datasources/remote/users_remote_datasource.dart';
import 'package:todoapp/domain/entities/user.dart';
import 'package:todoapp/domain/repositories/users_repository.dart';

class UsersRepositoryImpl extends UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  UsersRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException(message: 'Erreur réseau');
    }
    final remote = await _remoteDataSource.searchUsers(query);
    return remote.map((user) => user.toEntity()).toList();
  }
}

import 'package:dio/dio.dart';
import 'package:todoapp/core/constants/api_constants.dart';
import 'package:todoapp/core/errors/exceptions.dart';
import 'package:todoapp/core/services/api_service.dart';
import 'package:todoapp/data/models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> searchUsers(String query);
}

class UsersRemoteDataSourceImpl extends UsersRemoteDataSource {
  final ApiService _apiService;

  UsersRemoteDataSourceImpl(this._apiService);
  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.users}/search/$query',
      );
      final users = response.data as List;
      return users.map((user) => UserModel.fromJson(user)).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors de la recherche',
      );
    }
  }
}

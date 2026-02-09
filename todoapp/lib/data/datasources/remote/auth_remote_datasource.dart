import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/services/api_service.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(String email, String password, String? name);
  Future<UserModel> getCurrentUser();
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSourceImpl(this._apiService);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      return AuthResponse(
        user: UserModel.fromJson(response.data['user']),
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur de connexion',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthResponse> register(
    String email,
    String password,
    String? name,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );

      return AuthResponse(
        user: UserModel.fromJson(response.data['user']),
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors de l\'inscription',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors du chargement',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

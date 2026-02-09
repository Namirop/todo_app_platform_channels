import 'package:dio/dio.dart';
import 'package:todoapp/data/models/list_share_model.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/services/api_service.dart';
import '../../models/list_model.dart';

abstract class ListsRemoteDataSource {
  Future<(List<ListModel> ownedLists, List<ListModel> sharedLists)> getLists();
  Future<ListModel> getListById(String id);
  Future<ListModel> createList(String name);
  Future<ListModel> updateList(String id, {String? name});
  Future<void> deleteList(String id);
  Future<Map<String, dynamic>> shareList(
    String listId,
    List<Map<String, String>> shares,
  );
  Future<void> removeShare(String listId);
  Future<List<ListShareModel>> getListShares(String listId);
}

class ListsRemoteDataSourceImpl implements ListsRemoteDataSource {
  final ApiService _apiService;

  ListsRemoteDataSourceImpl(this._apiService);

  @override
  Future<(List<ListModel> ownedLists, List<ListModel> sharedLists)>
  getLists() async {
    try {
      final response = await _apiService.get(ApiConstants.lists);

      final ownedJson = response.data['ownedLists'] as List;
      final sharedJson = response.data['sharedLists'] as List;

      final ownedLists = ownedJson
          .map((json) => ListModel.fromJson(json))
          .toList();

      final sharedLists = sharedJson
          .map((json) => ListModel.fromJson(json))
          .toList();

      return (ownedLists, sharedLists);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors du chargement',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ListModel> getListById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.lists}/$id');
      return ListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Liste non trouvée',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ListModel> createList(String name) async {
    try {
      final response = await _apiService.post(
        ApiConstants.lists,
        data: {'name': name},
      );

      return ListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors de la création',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ListModel> updateList(String id, {String? name}) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.lists}/$id',
        data: {if (name != null) 'name': name},
      );

      return ListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors de la mise à jour',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteList(String id) async {
    try {
      await _apiService.delete('${ApiConstants.lists}/$id');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors de la suppression',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> shareList(
    String listId,
    List<Map<String, String>> shares,
  ) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.lists}/$listId/shares',
        data: {'shares': shares},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print("DioException");
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data['error'] as String?;

      switch (statusCode) {
        case 400:
          throw ValidationException(
            message: errorMessage ?? 'Données invalides',
          );

        case 403:
          throw ForbiddenException(
            message: errorMessage ?? 'Vous n\'êtes pas autorisé',
          );

        case 404:
          throw NotFoundException(message: errorMessage ?? 'Liste introuvable');

        case 503:
          throw ServerException(
            message: 'Le serveur rencontre un problème, réessayez plus tard',
            statusCode: statusCode,
          );
        default:
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            throw NetworkException(message: 'La connexion a expiré');
          }

          if (e.type == DioExceptionType.connectionError) {
            throw NetworkException(
              message: 'Impossible de contacter le serveur',
            );
          }

          throw ServerException(
            message: errorMessage ?? 'Une erreur est survenue',
            statusCode: statusCode,
          );
      }
    } catch (e) {
      // non-http error (parsing, etc.)
      print("Unknown error : ${e.toString()}");
      throw UnknownException(message: e.toString());
    }
  }

  @override
  Future<void> removeShare(String listId) async {
    try {
      await _apiService.delete('${ApiConstants.lists}/$listId/shares');
    } on DioException catch (e) {
      throw ServerException(
        message:
            e.response?.data['error'] ??
            'Erreur lors de la suppression du partage',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ListShareModel>> getListShares(String listId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.lists}/$listId/shares',
      );

      return (response.data as List)
          .map((json) => ListShareModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Erreur lors du chargement',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

import 'package:todoapp/domain/entities/list_share.dart';

class ListShareModel {
  final String id;
  final String listId;
  final String userId;
  final String permission;
  final DateTime createdAt;

  const ListShareModel({
    required this.id,
    required this.listId,
    required this.userId,
    required this.permission,
    required this.createdAt,
  });

  factory ListShareModel.fromJson(Map<String, dynamic> json) {
    return ListShareModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      userId: json['userId'] as String,
      permission: json['permission'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'userId': userId,
      'permission': permission,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ListShare toEntity() {
    return ListShare(
      id: id,
      listId: listId,
      userId: userId,
      permission: SharePermission.fromString(permission),
      createdAt: createdAt,
    );
  }

  factory ListShareModel.fromEntity(ListShare entity) {
    return ListShareModel(
      id: entity.id,
      listId: entity.listId,
      userId: entity.userId,
      permission: entity.permission.toJson(),
      createdAt: entity.createdAt,
    );
  }
}

import '../../domain/entities/list.dart';

class ListModel {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final String? permission;
  final String? ownerName;
  final String? ownerMail;
  final int todosCount;

  const ListModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.permission = 'write',
    this.ownerName,
    this.ownerMail,
    required this.todosCount,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isShared: json['isShared'] as bool? ?? false,
      permission: json['permission'] as String? ?? 'write',
      ownerName: json['ownerName'] as String? ?? 'n/a',
      ownerMail: json['ownerMail'] as String? ?? 'n/a',
      todosCount: json['todosCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isShared': isShared,
      if (permission != null) 'permission': permission,
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerMail != null) 'ownerMail': ownerMail,
      'todosCount': todosCount,
    };
  }

  ListEntity toEntity() {
    return ListEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isShared: isShared,
      permission: permission,
      ownerName: ownerName,
      ownerMail: ownerMail,
      todosCount: todosCount,
    );
  }

  factory ListModel.fromEntity(ListEntity entity) {
    return ListModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isShared: entity.isShared,
      permission: entity.permission,
      ownerName: entity.ownerName,
      ownerMail: entity.ownerMail,
      todosCount: entity.todosCount,
    );
  }

  ListModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    String? permission,
    String? ownerName,
    String? ownerMail,
    int? todosCount,
  }) {
    return ListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      permission: permission ?? this.permission,
      ownerName: ownerName ?? this.ownerName,
      ownerMail: ownerMail ?? this.ownerMail,
      todosCount: todosCount ?? this.todosCount,
    );
  }
}

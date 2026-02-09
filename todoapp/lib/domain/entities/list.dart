class ListEntity {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isShared;
  final String? permission;
  final String? ownerName;
  final int todosCount;

  const ListEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.isShared,
    required this.permission,
    required this.ownerName,
    required this.todosCount,
  });

  bool isOwnedBy(String userId) => ownerId == userId;

  ListEntity copyWith({
    String? id,
    String? name,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    String? permission,
    String? ownerName,
    int? todoCount,
  }) {
    return ListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      permission: permission,
      ownerName: ownerName,
      todosCount: todoCount ?? todosCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

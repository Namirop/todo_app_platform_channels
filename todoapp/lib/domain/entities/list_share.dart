enum SharePermission {
  read,
  write;

  static SharePermission fromString(String value) {
    return switch (value) {
      'write' => SharePermission.write,
      _ => SharePermission.read,
    };
  }

  String toJson() => name;
}

class ListShare {
  final String id;
  final String listId;
  final String userId;
  final SharePermission permission;
  final DateTime createdAt;

  const ListShare({
    required this.id,
    required this.listId,
    required this.userId,
    required this.permission,
    required this.createdAt,
  });

  bool get canWrite => permission == SharePermission.write;
  bool get canRead => true; // All shares can read

  ListShare copyWith({
    String? id,
    String? listId,
    String? userId,
    SharePermission? permission,
    DateTime? createdAt,
  }) {
    return ListShare(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      userId: userId ?? this.userId,
      permission: permission ?? this.permission,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListShare && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

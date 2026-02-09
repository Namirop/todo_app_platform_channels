class TodoEntity {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? dueDate;
  final int priority;
  final String listId;
  final String createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TodoListInfo? list;

  const TodoEntity({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    this.dueDate,
    required this.priority,
    required this.listId,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.list,
  });

  // Business logic helpers
  bool get isOverdue =>
      dueDate != null && !completed && dueDate!.isBefore(DateTime.now());

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueSoon {
    if (dueDate == null) return false;
    final diff = dueDate!.difference(DateTime.now());
    return diff.inDays <= 3 && diff.inDays >= 0;
  }

  String get priorityLabel {
    return switch (priority) {
      0 => 'Basse',
      1 => 'Normale',
      2 => 'Haute',
      3 => 'Urgente',
      _ => 'Normale',
    };
  }

  TodoEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
    int? priority,
    String? listId,
    String? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    TodoListInfo? list,
    bool clearDueDate = false,
    bool clearDescription = false,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      completed: completed ?? this.completed,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      listId: listId ?? this.listId,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      list: list ?? this.list,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TodoListInfo {
  final String id;
  final String name;

  const TodoListInfo({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoListInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

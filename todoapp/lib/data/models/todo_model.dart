import '../../domain/entities/todo.dart';

class TodoModel {
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
  final TodoListInfoModel? list;

  const TodoModel({
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

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      priority: json['priority'] as int,
      listId: json['listId'] as String,
      createdById: json['createdById'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      list: json['list'] != null
          ? TodoListInfoModel.fromJson(json['list'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'listId': listId,
      'createdById': createdById,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (list != null) 'list': list!.toJson(),
    };
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      description: description,
      completed: completed,
      dueDate: dueDate,
      priority: priority,
      listId: listId,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      list: list?.toEntity(),
    );
  }

  factory TodoModel.fromEntity(TodoEntity entity) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      completed: entity.completed,
      dueDate: entity.dueDate,
      priority: entity.priority,
      listId: entity.listId,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      list: entity.list != null
          ? TodoListInfoModel.fromEntity(entity.list!)
          : null,
    );
  }

  TodoModel copyWith({
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
    TodoListInfoModel? list,
    bool clearDueDate = false,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
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
}

class TodoListInfoModel {
  final String id;
  final String name;

  const TodoListInfoModel({required this.id, required this.name});

  factory TodoListInfoModel.fromJson(Map<String, dynamic> json) {
    return TodoListInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  TodoListInfo toEntity() {
    return TodoListInfo(id: id, name: name);
  }

  factory TodoListInfoModel.fromEntity(TodoListInfo entity) {
    return TodoListInfoModel(id: entity.id, name: entity.name);
  }
}

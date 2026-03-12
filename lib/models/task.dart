enum TaskStatus {
  todo,
  inProgress,
  done,
}

enum TaskPriority {
  low,
  medium,
  high,
}

/**
 * Extensions utilitaires sur TaskStatus
 */
extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:       return 'À faire';
      case TaskStatus.inProgress: return 'En cours';
      case TaskStatus.done:       return 'Terminée';
    }
  }

  String get value {
    switch (this) {
      case TaskStatus.todo:       return 'todo';
      case TaskStatus.inProgress: return 'inProgress';
      case TaskStatus.done:       return 'done';
    }
  }

  static TaskStatus fromValue(String value) {
    switch (value) {
      case 'inProgress': return TaskStatus.inProgress;
      case 'done':       return TaskStatus.done;
      case 'todo':
      default:           return TaskStatus.todo;
    }
  }
}

/**
 * Extensions utilitaires sur TaskPriority
 */
extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:    return 'Basse';
      case TaskPriority.medium: return 'Moyenne';
      case TaskPriority.high:   return 'Haute';
    }
  }

  String get value {
    switch (this) {
      case TaskPriority.low:    return 'low';
      case TaskPriority.medium: return 'medium';
      case TaskPriority.high:   return 'high';
    }
  }

  static TaskPriority fromValue(String value) {
    switch (value) {
      case 'high':   return TaskPriority.high;
      case 'medium': return TaskPriority.medium;
      case 'low':
      default:       return TaskPriority.low;
    }
  }
}

class Task {

  final String id;

  final String projectId;

  final String title;

  final String? description;

  final TaskStatus status;

  final TaskPriority priority;

  final DateTime? dueDate;

  final DateTime createdAt;

  final DateTime updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /**
   * Retourne true si la tâche est en retard
   */
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /**
   * Crée une copie de la tâche avec des champs modifiés
   */
  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /**
   * Convertir la tâche en Map pour la serialisation
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /**
   * Créer une tâche à l'aide du constructeur factory depuis un Map
   */
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatusExtension.fromValue(map['status'] as String? ?? 'todo'),
      priority: TaskPriorityExtension.fromValue(map['priority'] as String? ?? 'medium'),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: ${status.value}, priority: ${priority.value})';
  }
}
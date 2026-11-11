// How important a task is. The parent picks one of these in Add / Edit Task.
enum TaskPriority {
  low('Low'),
  normal('Normal'),
  high('High');

  const TaskPriority(this.label);

  // Text shown on screen, e.g. "High"
  final String label;
}

// How often a task repeats.
enum TaskRecurrence {
  never('Never'),
  daily('Daily'),
  weekly('Weekly'),
  custom('Custom');

  const TaskRecurrence(this.label);

  final String label;
}

class Task {
  Task({
    required this.id,
    required this.childId,
    required this.title,
    required this.stars,
    this.icon = '📝',
    this.priority = TaskPriority.normal,
    this.dueDate,
    this.recurrence = TaskRecurrence.never,
    this.customDays = const [],
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;

  // The child this task belongs to (we use the child's access code).
  final String childId;

  final String title;

  // Emoji shown next to the task, e.g. '📚' or '🧹'
  final String icon;

  // Stars the child earns when the task is completed
  final int stars;

  final TaskPriority priority;

  // null means the task can be done anytime
  final DateTime? dueDate;

  final TaskRecurrence recurrence;

  // Only used when recurrence is custom.
  // Uses DateTime.weekday numbers: 1 = Monday ... 7 = Sunday
  final List<int> customDays;

  // Not final because the child marks the task as completed
  bool isCompleted;
  DateTime? completedAt;

  final DateTime createdAt;

  // Short text for the due date: "Anytime", "Today", "Tomorrow" or "14 Nov"
  String get dueLabel {
    if (dueDate == null) return 'Anytime';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${due.day} ${months[due.month - 1]}';
  }

  // Creates a copy of this task with some fields changed.
  // Used when the parent edits a task.
  Task copyWith({
    String? childId,
    String? title,
    String? icon,
    int? stars,
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskRecurrence? recurrence,
    List<int>? customDays,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Task(
      id: id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      stars: stars ?? this.stars,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      recurrence: recurrence ?? this.recurrence,
      customDays: customDays ?? this.customDays,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }

  // Convert Task object to JSON (to save it in SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'icon': icon,
      'stars': stars,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'recurrence': recurrence.name,
      'customDays': customDays,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert JSON back to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      childId: json['childId'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? '📝',
      stars: json['stars'] as int,
      priority: TaskPriority.values.byName(json['priority'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      recurrence: TaskRecurrence.values.byName(json['recurrence'] as String),
      customDays: List<int>.from(json['customDays'] as List? ?? []),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

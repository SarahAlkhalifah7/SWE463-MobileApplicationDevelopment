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
    List<DateTime>? completionHistory,
    DateTime? createdAt,
  }) : completionHistory = completionHistory ?? [],
       createdAt = createdAt ?? DateTime.now();

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

  // Not final because the child marks the task as completed.
  // For repeating tasks these mean "completed for the current day",
  // and they are reset when the task's next day comes.
  bool isCompleted;
  DateTime? completedAt;

  // Every time the child completed this task. Repeating tasks are
  // completed many times, so stars and streaks are counted from here.
  final List<DateTime> completionHistory;

  final DateTime createdAt;

  bool get isRecurring => recurrence != TaskRecurrence.never;

  // How many times the task was completed, and the stars earned from it
  int get timesCompleted => completionHistory.length;
  int get earnedStars => stars * timesCompleted;

  // Called when the child presses Complete
  void markCompleted() {
    final now = DateTime.now();
    isCompleted = true;
    completedAt = now;
    completionHistory.add(now);
  }

  // Removes the time part of a date (14 Nov 16:30 -> 14 Nov 00:00)
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Does a repeating task happen on this day?
  // The task starts on its due date, or on the day it was created.
  bool isScheduledOn(DateTime day) {
    final start = dateOnly(dueDate ?? createdAt);
    final date = dateOnly(day);

    if (date.isBefore(start)) return false;

    switch (recurrence) {
      case TaskRecurrence.never:
        return date == start;
      case TaskRecurrence.daily:
        return true;
      case TaskRecurrence.weekly:
        return date.weekday == start.weekday;
      case TaskRecurrence.custom:
        return customDays.contains(date.weekday);
    }
  }

  // Should this task appear in the child's "Today's Missions"?
  bool get isForToday {
    final today = dateOnly(DateTime.now());

    if (isRecurring) return isScheduledOn(today);

    // One-time task: show it until it is done (including late tasks),
    // and keep showing it on the day it was completed.
    if (isCompleted) {
      return completedAt != null && dateOnly(completedAt!) == today;
    }
    return dueDate == null || !dateOnly(dueDate!).isAfter(today);
  }

  // A repeating task that was completed before should become pending
  // again once one of its scheduled days has come.
  bool get needsReset {
    if (!isRecurring || !isCompleted || completedAt == null) return false;

    final today = dateOnly(DateTime.now());
    var day = dateOnly(completedAt!).add(const Duration(days: 1));

    // Every schedule repeats weekly, so checking 7 days is enough
    for (var i = 0; i < 7 && !day.isAfter(today); i++) {
      if (isScheduledOn(day)) return true;
      day = day.add(const Duration(days: 1));
    }
    return false;
  }

  void reset() {
    isCompleted = false;
    completedAt = null;
  }

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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
      completionHistory: List<DateTime>.from(completionHistory),
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
      'completionHistory': completionHistory
          .map((date) => date.toIso8601String())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert JSON back to Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    final completedAt = json['completedAt'] == null
        ? null
        : DateTime.parse(json['completedAt'] as String);
    final isCompleted = json['isCompleted'] as bool? ?? false;

    // Tasks saved before the history existed: use their completedAt
    final history = json['completionHistory'] == null
        ? <DateTime>[if (isCompleted && completedAt != null) completedAt]
        : (json['completionHistory'] as List)
              .map((date) => DateTime.parse(date as String))
              .toList();

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
      isCompleted: isCompleted,
      completedAt: completedAt,
      completionHistory: history,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// Helpers for a list of tasks, e.g. tasks.forToday or tasks.totalEarnedStars
extension TaskListStats on List<Task> {
  // The tasks the child should do today
  List<Task> get forToday => where((task) => task.isForToday).toList();

  // Total number of completions (a daily task done 3 days counts 3)
  int get totalCompletions =>
      fold(0, (total, task) => total + task.timesCompleted);

  // All stars ever earned from these tasks
  int get totalEarnedStars =>
      fold(0, (total, task) => total + task.earnedStars);

  // Every different day on which at least one task was completed
  Set<DateTime> get completionDays => {
    for (final task in this)
      for (final date in task.completionHistory) Task.dateOnly(date),
  };
}

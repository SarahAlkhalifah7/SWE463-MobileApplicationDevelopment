class Task {
  Task({
    required this.id,
    required this.childId,
    required this.title,
    required this.stars,
    this.isCompleted = false,
    this.priority = 'Normal',
    this.dueLabel = 'Today',
  });

  final String id;
  final String childId;
  final String title;
  final int stars;
  bool isCompleted;
  final String priority;
  final String dueLabel;
}
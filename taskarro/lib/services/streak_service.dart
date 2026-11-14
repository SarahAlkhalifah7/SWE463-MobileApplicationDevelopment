import 'task_storage.dart';

class StreakService {
  // Returns the child's current streak based on task completion dates.
  static Future<int> getCurrentStreak(String childId) async {
    final tasks = await TaskStorage.getTasksForChild(childId);

    // Get completion dates only.
    final completedDates = tasks
        .where((task) => task.isCompleted && task.completedAt != null)
        .map(
          (task) => DateTime(
            task.completedAt!.year,
            task.completedAt!.month,
            task.completedAt!.day,
          ),
        )
        .toSet()
        .toList();

    if (completedDates.isEmpty) {
      return 0;
    }

    // Newest completion date first.
    completedDates.sort((a, b) => b.compareTo(a));

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final latestDate = completedDates.first;

    final daysSinceLatest = today.difference(latestDate).inDays;

    // A current streak can continue from today or yesterday.
    if (daysSinceLatest > 1) {
      return 0;
    }

    int streak = 1;

    DateTime expectedPreviousDay = latestDate.subtract(const Duration(days: 1));

    for (int i = 1; i < completedDates.length; i++) {
      final date = completedDates[i];

      if (date == expectedPreviousDay) {
        streak++;

        expectedPreviousDay = expectedPreviousDay.subtract(
          const Duration(days: 1),
        );
      } else if (date.isBefore(expectedPreviousDay)) {
        break;
      }
    }

    return streak;
  }
}

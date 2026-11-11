import 'reward_storage.dart';
import 'task_storage.dart';

// Works out a child's stars from their saved tasks and rewards.
// Stars are not saved separately, so they can never get out of sync.
class StarService {
  // All stars the child has earned from completed tasks
  static Future<int> getEarnedStars(String childId) async {
    final tasks = await TaskStorage.getTasksForChild(childId);

    return tasks
        .where((task) => task.isCompleted)
        .fold<int>(0, (total, task) => total + task.stars);
  }

  // Stars already spent on rewards the parent has given
  static Future<int> getSpentStars(String childId) async {
    final rewards = await RewardStorage.getRewardsForChild(childId);

    return rewards
        .where((reward) => reward.isRedeemed)
        .fold<int>(0, (total, reward) => total + reward.requiredStars);
  }

  // Stars the child can still use for new rewards
  static Future<int> getAvailableStars(String childId) async {
    final earned = await getEarnedStars(childId);
    final spent = await getSpentStars(childId);

    final available = earned - spent;
    return available > 0 ? available : 0;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskarro/models/reward.dart';
import 'package:taskarro/models/task.dart';
import 'package:taskarro/services/reward_storage.dart';
import 'package:taskarro/services/star_service.dart';
import 'package:taskarro/services/task_storage.dart';

void main() {
  const childId = '1234';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Start every test with empty fake storage
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Task makeTask(String id, {int stars = 10, String child = childId}) {
    return Task(id: id, childId: child, title: 'Task $id', stars: stars);
  }

  group('TaskStorage', () {
    test('add, update and delete a task', () async {
      await TaskStorage.addTask(makeTask('1'));
      expect((await TaskStorage.getTasks()).length, 1);

      final task = (await TaskStorage.getTasks()).first;
      await TaskStorage.updateTask(task.copyWith(title: 'Read a book'));
      expect((await TaskStorage.getTasks()).first.title, 'Read a book');

      await TaskStorage.deleteTask('1');
      expect(await TaskStorage.getTasks(), isEmpty);
    });

    test('only returns the tasks of the chosen child', () async {
      await TaskStorage.addTask(makeTask('1'));
      await TaskStorage.addTask(makeTask('2', child: '9999'));

      final tasks = await TaskStorage.getTasksForChild(childId);

      expect(tasks.length, 1);
      expect(tasks.first.id, '1');
    });

    test('daily task completed yesterday is pending again today', () async {
      final task = Task(
        id: 'd1',
        childId: childId,
        title: 'Brush teeth',
        stars: 5,
        recurrence: TaskRecurrence.daily,
        createdAt: yesterday,
        isCompleted: true,
        completedAt: yesterday,
        completionHistory: [yesterday],
      );
      await TaskStorage.addTask(task);

      final saved = (await TaskStorage.getTodayTasksForChild(childId)).first;

      expect(saved.isCompleted, isFalse);
      expect(saved.timesCompleted, 1);
    });
  });

  group('RewardStorage', () {
    test('next reward is the cheapest one not given yet', () async {
      await RewardStorage.addReward(
        Reward(id: 'a', childId: childId, title: 'Movie', requiredStars: 200),
      );
      await RewardStorage.addReward(
        Reward(
          id: 'b',
          childId: childId,
          title: 'Ice Cream',
          requiredStars: 50,
        ),
      );
      await RewardStorage.addReward(
        Reward(
          id: 'c',
          childId: childId,
          title: 'Sticker',
          requiredStars: 10,
          isRedeemed: true,
        ),
      );

      final next = await RewardStorage.getNextReward(childId);

      expect(next?.title, 'Ice Cream');
    });
  });

  group('StarService', () {
    test('available stars = earned stars - given rewards', () async {
      final task = makeTask('1', stars: 30);
      task.completionHistory.addAll([yesterday, today]); // done twice
      task.isCompleted = true;
      task.completedAt = today;
      await TaskStorage.addTask(task);

      await RewardStorage.addReward(
        Reward(
          id: 'r',
          childId: childId,
          title: 'Ice Cream',
          requiredStars: 20,
          isRedeemed: true,
        ),
      );

      expect(await StarService.getEarnedStars(childId), 60);
      expect(await StarService.getSpentStars(childId), 20);
      expect(await StarService.getAvailableStars(childId), 40);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:taskarro/models/reward.dart';
import 'package:taskarro/models/task.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final tomorrow = today.add(const Duration(days: 1));

  Task makeTask({
    TaskRecurrence recurrence = TaskRecurrence.never,
    DateTime? dueDate,
    List<int> customDays = const [],
    DateTime? createdAt,
  }) {
    return Task(
      id: '1',
      childId: '1234',
      title: 'Finish homework',
      stars: 10,
      recurrence: recurrence,
      dueDate: dueDate,
      customDays: customDays,
      createdAt: createdAt,
    );
  }

  group('Task JSON', () {
    test('toJson and fromJson keep all fields', () {
      final task = Task(
        id: 'abc',
        childId: '1234',
        title: 'Clean your room',
        icon: '🧹',
        stars: 5,
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 11, 20, 16, 0),
        recurrence: TaskRecurrence.custom,
        customDays: [1, 3, 5],
      )..markCompleted();

      final copy = Task.fromJson(task.toJson());

      expect(copy.id, 'abc');
      expect(copy.childId, '1234');
      expect(copy.title, 'Clean your room');
      expect(copy.icon, '🧹');
      expect(copy.stars, 5);
      expect(copy.priority, TaskPriority.high);
      expect(copy.dueDate, DateTime(2026, 11, 20, 16, 0));
      expect(copy.recurrence, TaskRecurrence.custom);
      expect(copy.customDays, [1, 3, 5]);
      expect(copy.isCompleted, isTrue);
      expect(copy.timesCompleted, 1);
    });

    test('old saved tasks without history use completedAt', () {
      final json = makeTask().toJson()
        ..remove('completionHistory')
        ..['isCompleted'] = true
        ..['completedAt'] = yesterday.toIso8601String();

      final task = Task.fromJson(json);

      expect(task.timesCompleted, 1);
      expect(task.earnedStars, 10);
    });
  });

  group('Task due label', () {
    test('shows Anytime, Today and Tomorrow', () {
      expect(makeTask().dueLabel, 'Anytime');
      expect(makeTask(dueDate: today).dueLabel, 'Today');
      expect(makeTask(dueDate: tomorrow).dueLabel, 'Tomorrow');
    });
  });

  group('Task scheduling', () {
    test('one-time task shows until it is completed', () {
      final task = makeTask();
      expect(task.isForToday, isTrue);

      task.markCompleted();
      expect(task.isForToday, isTrue); // still shown on the day it was done
    });

    test('one-time task due in the future is not for today', () {
      expect(makeTask(dueDate: tomorrow).isForToday, isFalse);
    });

    test('daily task is for today', () {
      final task = makeTask(
        recurrence: TaskRecurrence.daily,
        createdAt: yesterday,
      );
      expect(task.isForToday, isTrue);
    });

    test('weekly task only shows on its weekday', () {
      final task = makeTask(recurrence: TaskRecurrence.weekly, dueDate: today);

      expect(task.isScheduledOn(today), isTrue);
      expect(task.isScheduledOn(tomorrow), isFalse);
      expect(task.isScheduledOn(today.add(const Duration(days: 7))), isTrue);
    });

    test('custom task only shows on chosen days', () {
      final task = makeTask(
        recurrence: TaskRecurrence.custom,
        customDays: [today.weekday],
        createdAt: yesterday,
      );

      expect(task.isScheduledOn(today), isTrue);
      expect(task.isScheduledOn(tomorrow), isFalse);
    });
  });

  group('Task repeating reset', () {
    test('daily task completed yesterday needs reset', () {
      final task = makeTask(
        recurrence: TaskRecurrence.daily,
        createdAt: yesterday,
      );
      task.isCompleted = true;
      task.completedAt = yesterday;
      task.completionHistory.add(yesterday);

      expect(task.needsReset, isTrue);

      task.reset();
      expect(task.isCompleted, isFalse);
      expect(task.timesCompleted, 1); // history and stars are kept
    });

    test('daily task completed today does not need reset', () {
      final task = makeTask(recurrence: TaskRecurrence.daily)..markCompleted();

      expect(task.needsReset, isFalse);
    });

    test('one-time task never resets', () {
      final task = makeTask();
      task.isCompleted = true;
      task.completedAt = yesterday;

      expect(task.needsReset, isFalse);
    });
  });

  group('Task list helpers', () {
    test('count completions, stars and days', () {
      final daily = makeTask(recurrence: TaskRecurrence.daily);
      daily.completionHistory.addAll([yesterday, today]);

      final once = makeTask()..markCompleted();

      final tasks = [daily, once];

      expect(tasks.totalCompletions, 3);
      expect(tasks.totalEarnedStars, 30);
      expect(tasks.completionDays, {yesterday, today});
    });
  });

  group('Reward', () {
    final reward = Reward(
      id: 'r1',
      childId: '1234',
      title: 'Ice Cream',
      icon: '🍦',
      requiredStars: 100,
    );

    test('availability and stars needed', () {
      expect(reward.isAvailable(80), isFalse);
      expect(reward.starsNeeded(80), 20);
      expect(reward.isAvailable(100), isTrue);
      expect(reward.starsNeeded(150), 0);
    });

    test('progress stays between 0 and 1', () {
      expect(reward.progress(0), 0.0);
      expect(reward.progress(50), 0.5);
      expect(reward.progress(500), 1.0);
    });

    test('toJson and fromJson keep all fields', () {
      final given = reward.copyWith(
        isRedeemed: true,
        redeemedAt: DateTime(2026, 11, 14),
      );

      final copy = Reward.fromJson(given.toJson());

      expect(copy.title, 'Ice Cream');
      expect(copy.icon, '🍦');
      expect(copy.requiredStars, 100);
      expect(copy.isRedeemed, isTrue);
      expect(copy.redeemedAt, DateTime(2026, 11, 14));
    });
  });
}

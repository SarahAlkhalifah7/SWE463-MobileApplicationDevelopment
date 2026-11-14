import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/reward.dart';
import '../models/task.dart';
import '../services/reward_storage.dart';
import '../services/star_service.dart';
import '../services/task_storage.dart';

class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  List<Task> _tasks = [];
  int _availableStars = 0;
  Reward? _nextReward;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final childId = widget.child.accessCode;
    final tasks = await TaskStorage.getTasksForChild(childId);
    final stars = await StarService.getAvailableStars(childId);
    final nextReward = await RewardStorage.getNextReward(childId);

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _availableStars = stars;
      _nextReward = nextReward;
      _isLoading = false;
    });
  }

  // Counts every completion, so a daily task done 3 days counts 3
  int get _completedTasks => _tasks.totalCompletions;

  int get _completedDaysThisWeek {
    final now = DateTime.now();
    final weekStart = Task.dateOnly(
      now.subtract(Duration(days: now.weekday - 1)),
    );

    final days = _tasks.completionDays
        .where((day) => !day.isBefore(weekStart))
        .length;

    return days.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF9F0),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7563E8),
          ),
        ),
      );
    }

    // Progress towards the next reward the parent created
    final starProgress = _nextReward?.progress(_availableStars) ?? 0.0;
    final challengeProgress = (_completedDaysThisWeek / 5)
        .clamp(0.0, 1.0)
        .toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              '${widget.child.name}’s Reward Journey',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29283A),
              ),
            ),

            const SizedBox(height: 18),

            _RewardProgressCard(
              stars: _availableStars,
              reward: _nextReward,
              progress: starProgress,
            ),

            const SizedBox(height: 18),

            _JourneyCard(
              progress: starProgress,
            ),

            const SizedBox(height: 18),

            _StreakCard(
              completedDays: _completedDaysThisWeek,
            ),

            const SizedBox(height: 18),

            _WeeklyChallengeCard(
              completedDays: _completedDaysThisWeek,
              progress: challengeProgress,
            ),

            const SizedBox(height: 18),

            Text(
              'Completed tasks: $_completedTasks',
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardProgressCard extends StatelessWidget {
  const _RewardProgressCard({
    required this.stars,
    required this.reward,
    required this.progress,
  });

  final int stars;
  final Reward? reward;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final reward = this.reward;
    final starsLeft = reward?.starsNeeded(stars) ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reward?.icon ?? '🎁',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reward?.title ?? 'No reward yet',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reward == null
                ? 'Ask your parent to add a reward!'
                : 'Your next reward',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF7563E8),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            reward == null
                ? '$stars stars'
                : '${stars.clamp(0, reward.requiredStars)} / '
                    '${reward.requiredStars} stars',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF7563E8),
            ),
          ),
          if (reward != null) ...[
            const SizedBox(height: 4),
            Text(
              starsLeft > 0
                  ? '$starsLeft more stars to unlock!'
                  : 'Reward unlocked!',
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final started = progress > 0;
    final reachedProgress = progress >= 0.5;
    final rewardUnlocked = progress >= 1;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8E3F5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your adventure',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep completing missions to move forward.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _JourneyStep(
                    icon: Icons.flag,
                    label: 'Start',
                    completed: started,
                  ),
                  _JourneyLine(completed: reachedProgress),
                  _JourneyStep(
                    icon: Icons.star,
                    label: 'Progress',
                    completed: reachedProgress,
                  ),
                  _JourneyLine(completed: rewardUnlocked),
                  _JourneyStep(
                    icon: Icons.card_giftcard,
                    label: 'Reward',
                    completed: rewardUnlocked,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.icon,
    required this.label,
    required this.completed,
  });

  final IconData icon;
  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: completed
              ? const Color(0xFF7563E8)
              : const Color(0xFFEAE7F8),
          child: Icon(
            icon,
            color: completed ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: completed
                ? const Color(0xFF7563E8)
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _JourneyLine extends StatelessWidget {
  const _JourneyLine({
    required this.completed,
  });

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35,
      height: 5,
      color: completed
          ? const Color(0xFF7563E8)
          : const Color(0xFFEAE7F8),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.completedDays,
  });

  final int completedDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0B9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 38),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Streak',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedDays days',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE09D00),
                ),
              ),
              const Text('Keep going!'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChallengeCard extends StatelessWidget {
  const _WeeklyChallengeCard({
    required this.completedDays,
    required this.progress,
  });

  final int completedDays;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE8E3F5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFC94A),
                  size: 30,
                ),
                SizedBox(width: 10),
                Text(
                  'Weekly Challenge',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Complete tasks for 5 days this week.',
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF7563E8),
              backgroundColor: const Color(0xFFEAE7F8),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedDays of 5 days completed',
              style: const TextStyle(
                color: Color(0xFF7563E8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mystery reward: 50 stars 🎁',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
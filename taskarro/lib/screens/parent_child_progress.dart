import 'dart:io';

import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/reward.dart';
import '../models/task.dart';
import '../services/reward_storage.dart';
import '../services/star_service.dart';
import '../services/task_storage.dart';

class ParentChildProgressScreen extends StatefulWidget {
  const ParentChildProgressScreen({super.key, required this.child});

  final Child child;

  @override
  State<ParentChildProgressScreen> createState() =>
      _ParentChildProgressScreenState();
}

class _ParentChildProgressScreenState extends State<ParentChildProgressScreen> {
  bool _isLoading = true;

  List<Task> _tasks = [];
  List<Reward> _rewards = [];

  int _earnedStars = 0;
  int _availableStars = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final childId = widget.child.accessCode;

    final tasks = await TaskStorage.getTasksForChild(childId);

    final rewards = await RewardStorage.getRewardsForChild(childId);

    final earnedStars = await StarService.getEarnedStars(childId);

    final availableStars = await StarService.getAvailableStars(childId);

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _rewards = rewards;
      _earnedStars = earnedStars;
      _availableStars = availableStars;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9F0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          title: Text('${widget.child.name}\'s Progress'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Real task data
    final completedTasks = _tasks.where((task) => task.isCompleted).length;

    final totalTasks = _tasks.length;

    final double taskProgress = totalTasks == 0
        ? 0
        : completedTasks / totalTasks;

    // Rewards that have not been given yet
    final activeRewards = _rewards
        .where((reward) => !reward.isRedeemed)
        .toList();

    // Cheapest reward first
    activeRewards.sort((a, b) => a.requiredStars.compareTo(b.requiredStars));

    final Reward? nextReward = activeRewards.isEmpty
        ? null
        : activeRewards.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.child.name}\'s Progress',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadProgress,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Child profile
            _buildProfile(),

            const SizedBox(height: 24),

            // Stars
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: '⭐',
                    value: '$_earnedStars',
                    label: 'Stars Earned',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildStatCard(
                    icon: '🔥',
                    value: '-',
                    label: 'Day Streak',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Task progress
            _buildTasksCard(
              completedTasks: completedTasks,
              totalTasks: totalTasks,
              progress: taskProgress,
            ),

            const SizedBox(height: 18),

            // Reward progress
            _buildRewardCard(nextReward),

            const SizedBox(height: 18),

            // Summary
            _buildSummary(
              completedTasks: completedTasks,
              totalTasks: totalTasks,
            ),
          ],
        ),
      ),
    );
  }

  // Child profile
  Widget _buildProfile() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF2EFFF),
            shape: BoxShape.circle,
          ),
          child: widget.child.photoPath != null
              ? ClipOval(
                  child: Image.file(
                    File(widget.child.photoPath!),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          widget.child.avatar,
                          style: const TextStyle(fontSize: 48),
                        ),
                      );
                    },
                  ),
                )
              : Text(widget.child.avatar, style: const TextStyle(fontSize: 48)),
        ),

        const SizedBox(height: 12),

        Text(
          widget.child.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        const Text('Progress Overview', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // Stars card
  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3F5)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Task progress
  Widget _buildTasksCard({
    required int completedTasks,
    required int totalTasks,
    required double progress,
  }) {
    return _buildSection(
      title: 'Task Progress',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks Completed',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              Text(
                '$completedTasks / $totalTasks',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFEDEAF5),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                color: Color(0xFF7563E8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (totalTasks == 0) ...[
            const SizedBox(height: 10),

            const Text(
              'No tasks assigned yet.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // Reward progress
  Widget _buildRewardCard(Reward? nextReward) {
    if (nextReward == null) {
      return _buildSection(
        title: 'Reward Progress',
        child: const Row(
          children: [
            Text('🎁', style: TextStyle(fontSize: 32)),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                'No reward set yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final requiredStars = nextReward.requiredStars;

    final double rewardProgress = requiredStars == 0
        ? 0
        : (_availableStars / requiredStars).clamp(0.0, 1.0);

    final starsNeeded = requiredStars - _availableStars;

    return _buildSection(
      title: 'Reward Progress',
      child: Column(
        children: [
          Row(
            children: [
              Text(nextReward.icon, style: const TextStyle(fontSize: 32)),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Reward',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    Text(
                      nextReward.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '$requiredStars stars required',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: rewardProgress,
              minHeight: 9,
              backgroundColor: const Color(0xFFEDEAF5),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_availableStars / $requiredStars stars',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7563E8),
                ),
              ),

              Text(
                starsNeeded <= 0 ? 'Ready! 🎉' : '$starsNeeded more needed',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Summary
  Widget _buildSummary({required int completedTasks, required int totalTasks}) {
    return _buildSection(
      title: 'Summary',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(value: '$completedTasks', label: 'Completed'),

          _SummaryItem(value: '$totalTasks', label: 'Total Tasks'),

          _SummaryItem(value: '$_earnedStars', label: 'Stars Earned'),
        ],
      ),
    );
  }

  // General section card
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

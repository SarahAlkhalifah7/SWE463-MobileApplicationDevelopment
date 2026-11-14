import 'package:flutter/material.dart';

import '../models/parent.dart';

import 'dart:io';

import 'add_child.dart';

import 'package:flutter/services.dart';

import 'parent_child_progress.dart';
import '../models/reward.dart';
import '../services/reward_storage.dart';
import '../services/star_service.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../services/streak_service.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({
    super.key,
    required this.parent,
    required this.onParentUpdated,
  });

  final ParentAccount parent;
  final ValueChanged<ParentAccount> onParentUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF9F0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(
                  'Hello, ${parent.name}! 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF29283A),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Here's how your little stars are doing.",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // My Children title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Children',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${parent.children.length} children',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Child cards
                ...parent.children.map(
                  (child) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE8E3F5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 60,
                              height: 60,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF2EFFF),
                                shape: BoxShape.circle,
                              ),
                              child: child.photoPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(child.photoPath!),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  child.avatar,
                                                  style: const TextStyle(
                                                    fontSize: 34,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Text(
                                      child.avatar,
                                      style: const TextStyle(fontSize: 34),
                                    ),
                            ),

                            const SizedBox(width: 14),

                            // Child name + code
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Child Code: ${child.accessCode}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        tooltip: 'Copy child code',
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(
                                              text: child.accessCode,
                                            ),
                                          );

                                          if (!context.mounted) return;

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${child.name}\'s code copied!',
                                              ),
                                              duration: const Duration(
                                                seconds: 1,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Stars and streak
                        Row(
                          children: [
                            Expanded(
                              child: FutureBuilder<int>(
                                future: StarService.getAvailableStars(
                                  child.accessCode,
                                ),
                                builder: (context, snapshot) {
                                  final stars = snapshot.data ?? 0;

                                  return _buildStat(
                                    icon: '⭐',
                                    value: '$stars',
                                    label: 'Stars',
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: FutureBuilder<int>(
                                future: StreakService.getCurrentStreak(
                                  child.accessCode,
                                ),
                                builder: (context, snapshot) {
                                  final streak = snapshot.data ?? 0;

                                  return _buildStat(
                                    icon: '🔥',
                                    value: '$streak',
                                    label: 'Day Streak',
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Today's Missions
                        // Today's Missions
                        FutureBuilder<List<Task>>(
                          future: TaskStorage.getTasksForChild(
                            child.accessCode,
                          ),
                          builder: (context, snapshot) {
                            final tasks = snapshot.data ?? [];

                            final completedTasks = tasks
                                .where((task) => task.isCompleted)
                                .length;

                            final totalTasks = tasks.length;

                            final progress = totalTasks == 0
                                ? 0.0
                                : completedTasks / totalTasks;

                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Today's Missions",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$completedTasks / $totalTasks',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: const Color(0xFFEDEAF5),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // Reward
                        FutureBuilder<List<Reward>>(
                          future: RewardStorage.getRewardsForChild(
                            child.accessCode,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final rewards = snapshot.data ?? [];

                            // Get rewards that have not been given yet
                            final activeRewards = rewards
                                .where((reward) => !reward.isRedeemed)
                                .toList();

                            // No rewards yet
                            if (activeRewards.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8E6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🎁', style: TextStyle(fontSize: 25)),

                                    SizedBox(width: 10),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Next Reward',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),

                                          Text(
                                            'No reward set yet',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Cheapest active reward = next reward
                            activeRewards.sort(
                              (a, b) =>
                                  a.requiredStars.compareTo(b.requiredStars),
                            );

                            final nextReward = activeRewards.first;

                            return FutureBuilder<int>(
                              future: StarService.getAvailableStars(
                                child.accessCode,
                              ),
                              builder: (context, starSnapshot) {
                                final stars = starSnapshot.data ?? 0;

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E6),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        nextReward.icon,
                                        style: const TextStyle(fontSize: 25),
                                      ),

                                      const SizedBox(width: 10),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Next Reward',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),

                                            Text(
                                              nextReward.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 3),

                                            Text(
                                              '$stars / ${nextReward.requiredStars} stars',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ParentChildProgressScreen(child: child),
                              ),
                            );
                          },
                          child: const Text('View Progress →'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // Add child button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updatedParent = await Navigator.push<ParentAccount>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddChildScreen(parent: parent),
                        ),
                      );

                      if (updatedParent != null) {
                        onParentUpdated(updatedParent);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Child'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required String icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

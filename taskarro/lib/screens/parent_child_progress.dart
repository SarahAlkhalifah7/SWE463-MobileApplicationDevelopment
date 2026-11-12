import 'dart:io';

import 'package:flutter/material.dart';

import '../models/child.dart';

class ParentChildProgressScreen extends StatelessWidget {
  const ParentChildProgressScreen({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    // Temporary values until Tasks/Rewards are connected.
    const int completedTasks = 0;
    const int totalTasks = 0;
    const int stars = 0;
    const int streak = 0;

    final double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),

      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          '${child.name}\'s Progress',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // Child profile
                  _buildProfile(context),

                  const SizedBox(height: 24),

                  // Stars + Streak
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: '⭐',
                          value: '$stars',
                          label: 'Stars Earned',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: '🔥',
                          value: '$streak',
                          label: 'Day Streak',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Today's progress
                  _buildSection(
                    title: "Today's Progress",
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Missions Completed',
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Reward progress
                  _buildSection(
                    title: 'Reward Progress',
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text('🎁', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const LinearProgressIndicator(
                            value: 0,
                            minHeight: 9,
                            backgroundColor: Color(0xFFEDEAF5),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '0 stars earned',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Weekly summary
                  _buildSection(
                    title: 'Weekly Summary',
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(value: '0', label: 'Tasks'),
                        _SummaryItem(value: '0', label: 'Stars'),
                        _SummaryItem(value: '0', label: 'Best Streak'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
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
          child: child.photoPath != null
              ? ClipOval(
                  child: Image.file(
                    File(child.photoPath!),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          child.avatar,
                          style: const TextStyle(fontSize: 48),
                        ),
                      );
                    },
                  ),
                )
              : Text(child.avatar, style: const TextStyle(fontSize: 48)),
        ),

        const SizedBox(height: 12),

        Text(
          child.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),

        const Text(
          'Keep up the great work! 🌟',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

class ChildChallengesScreen extends StatefulWidget {
  const ChildChallengesScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  State<ChildChallengesScreen> createState() =>
      _ChildChallengesScreenState();
}

class _ChildChallengesScreenState
    extends State<ChildChallengesScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskStorage.getTasksForChild(
      widget.child.accessCode,
    );

    if (!mounted) return;

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  int get _completedDaysThisWeek {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));

    // Days this week with at least one completed task (from task history)
    final days = _tasks.completionDays
        .where((day) => !day.isBefore(startOfWeek))
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

    final completedDays = _completedDaysThisWeek;
    final progress = (completedDays / 5)
        .clamp(0.0, 1.0)
        .toDouble();

    // No AppBar here: Child Mode already shows one for every tab
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Challenge',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF292640),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep going, ${widget.child.name}!',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            Card(
              color: const Color(0xFFEDE8FF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          '🔥',
                          style: TextStyle(fontSize: 36),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete 5 days this week',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292640),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Weekly progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292640),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.white,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(
                        Color(0xFF7563E8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$completedDays of 5 days completed',
                      style: const TextStyle(
                        color: Color(0xFF7563E8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              color: const Color(0xFFFFEEB5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      '🏆',
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            completedDays >= 5
                                ? 'Challenge completed!'
                                : 'Reward waiting!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF292640),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            completedDays >= 5
                                ? 'You unlocked the weekly reward!'
                                : 'Complete ${5 - completedDays} more day(s) to unlock it.',
                            style: const TextStyle(
                              color: Color(0xFF6E6240),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Current streak',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF292640),
              ),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Color(0xFFE5DFFF),
                ),
              ),
              child: ListTile(
                leading: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 32),
                ),
                title: Text(
                  '$completedDays day streak',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Complete tasks to keep building your streak!',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
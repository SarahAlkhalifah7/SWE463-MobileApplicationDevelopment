import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

class ChildTasksScreen extends StatefulWidget {
  const ChildTasksScreen({
    super.key,
    required this.child,
  });

  final Child child;

  @override
  State<ChildTasksScreen> createState() => _ChildTasksScreenState();
}

class _ChildTasksScreenState extends State<ChildTasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await TaskStorage.getTasksForChild(
        widget.child.accessCode,
      );

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load tasks.';
      });
    }
  }

  int get _earnedStars {
    return _tasks
        .where((task) => task.isCompleted)
        .fold(0, (total, task) => total + task.stars);
  }

  Future<void> _completeTask(Task task) async {
    if (task.isCompleted) return;

    setState(() {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
    });

    await TaskStorage.updateTask(task);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+${task.stars} stars earned!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks =
        _tasks.where((task) => task.isCompleted).length;

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

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9F0),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Text(
              'Hey, ${widget.child.name}! 👋',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29283A),
              ),
            ),
            const SizedBox(height: 16),

            _ProgressCard(
              stars: _earnedStars,
              completed: completedTasks,
              total: _tasks.length,
            ),

            const SizedBox(height: 26),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Missions 🚀",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completedTasks of ${_tasks.length} done',
                  style: const TextStyle(
                    color: Color(0xFF7563E8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE8E3F5),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 60,
                      color: Color(0xFF7563E8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your parent will add tasks for you soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._tasks.map(
                (task) => _TaskCard(
                  task: task,
                  onComplete: () => _completeTask(task),
                ),
              ),

            const SizedBox(height: 12),

            _RewardCard(
              earnedStars: _earnedStars,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.stars,
    required this.completed,
    required this.total,
  });

  final int stars;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star_rounded,
            color: Color(0xFFFFC94A),
            size: 42,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Stars',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '$stars',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7563E8),
                  ),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF7563E8),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            '🔥 0 day\nstreak',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onComplete,
  });

  final Task task;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: task.isCompleted
          ? const Color(0xFFEAF8F0)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE8E3F5),
        ),
      ),
      child: ListTile(
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: task.isCompleted
              ? const Color(0xFF48A878)
              : const Color(0xFF7563E8),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          '${task.dueLabel} • +${task.stars} stars',
        ),
        trailing: task.isCompleted
            ? const Text(
                'DONE',
                style: TextStyle(
                  color: Color(0xFF48A878),
                ),
              )
            : FilledButton(
                onPressed: onComplete,
                child: const Text('Complete'),
              ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.earnedStars,
  });

  final int earnedStars;

  @override
  Widget build(BuildContext context) {
    const requiredStars = 100;

    final progress =
        (earnedStars / requiredStars).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0B9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🍦 Next reward: Ice Cream',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFFE0A900),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 6),
          Text('$earnedStars / $requiredStars stars'),
        ],
      ),
    );
  }
}
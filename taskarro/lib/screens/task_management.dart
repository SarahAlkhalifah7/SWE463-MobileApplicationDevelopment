import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/parent.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import 'add_edit_task.dart';

// The three filter tabs at the top of the task list
enum TaskFilter { all, pending, completed }

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key, required this.parent});

  final ParentAccount parent;

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  static const Color purple = Color(0xFF7563E8);
  static const Color darkText = Color(0xFF29283A);
  static const Color border = Color(0xFFE8E3F5);
  static const Color lightPurple = Color(0xFFF2EFFF);

  // The child whose tasks are shown (null if the parent has no children)
  Child? _selectedChild;

  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.parent.children.isNotEmpty) {
      _selectedChild = widget.parent.children.first;
    }

    _loadTasks();
  }

  // Load the selected child's tasks from storage
  Future<void> _loadTasks() async {
    if (_selectedChild == null) {
      setState(() => _isLoading = false);
      return;
    }

    final tasks = await TaskStorage.getTasksForChild(
      _selectedChild!.accessCode,
    );

    if (!mounted) return;

    setState(() {
      _tasks = _sortTasks(tasks);
      _isLoading = false;
    });
  }

  // Pending tasks first, then by priority (High first), then by due date
  List<Task> _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }

      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    return tasks;
  }

  void _selectChild(Child child) {
    setState(() {
      _selectedChild = child;
      _filter = TaskFilter.all;
      _isLoading = true;
    });

    _loadTasks();
  }

  // Open the Add Task screen and reload the list if a task was saved
  Future<void> _openAddTask() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          children: widget.parent.children,
          selectedChild: _selectedChild!,
        ),
      ),
    );

    if (saved == true) {
      _loadTasks();
    }
  }

  // Open the same form in edit mode
  Future<void> _openEditTask(Task task) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTaskScreen(
          children: widget.parent.children,
          selectedChild: _selectedChild!,
          task: task,
        ),
      ),
    );

    if (saved == true) {
      _loadTasks();
    }
  }

  // Ask the parent before deleting
  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be removed for good.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await TaskStorage.deleteTask(task.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('"${task.title}" deleted')));

    _loadTasks();
  }

  // Quick priority change without opening the full form
  Future<void> _changePriority(Task task, TaskPriority priority) async {
    if (task.priority == priority) return;

    await TaskStorage.updateTask(task.copyWith(priority: priority));

    _loadTasks();
  }

  int get _pendingCount => _tasks.where((task) => !task.isCompleted).length;

  int get _completedCount => _tasks.where((task) => task.isCompleted).length;

  List<Task> get _filteredTasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
    }
  }

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
                _buildHeader(),
                const SizedBox(height: 20),
                if (_selectedChild == null)
                  _buildNoChildren()
                else if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _buildChildSelector(),
                  const SizedBox(height: 16),
                  if (_tasks.isEmpty)
                    _buildEmptyState()
                  else ...[
                    _buildSummary(),
                    const SizedBox(height: 16),
                    _buildFilterTabs(),
                    const SizedBox(height: 16),
                    _buildTaskList(),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // "Tasks" title with the purple + button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        if (_selectedChild != null)
          IconButton.filled(
            onPressed: _openAddTask,
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
            ),
            tooltip: 'Add task',
          ),
      ],
    );
  }

  // Card showing "Tasks for Sara" with a Switch menu
  Widget _buildChildSelector() {
    final child = _selectedChild!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: lightPurple,
              shape: BoxShape.circle,
            ),
            child: Text(child.avatar, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasks for',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (widget.parent.children.length > 1)
            PopupMenuButton<Child>(
              onSelected: _selectChild,
              itemBuilder: (context) => widget.parent.children
                  .map(
                    (c) => PopupMenuItem<Child>(
                      value: c,
                      child: Text('${c.avatar}  ${c.name}'),
                    ),
                  )
                  .toList(),
              child: const Row(
                children: [
                  Text(
                    'Switch',
                    style: TextStyle(
                      color: purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: purple),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // The two boxes: "2 Pending" and "1 Completed"
  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            icon: Icons.schedule,
            count: _pendingCount,
            label: 'Pending',
            color: purple,
            background: lightPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryBox(
            icon: Icons.check_circle_outline,
            count: _completedCount,
            label: 'Completed',
            color: const Color(0xFF2E9E5B),
            background: const Color(0xFFE6F6EC),
          ),
        ),
      ],
    );
  }

  // All / Pending / Completed tabs
  Widget _buildFilterTabs() {
    final counts = {
      TaskFilter.all: _tasks.length,
      TaskFilter.pending: _pendingCount,
      TaskFilter.completed: _completedCount,
    };

    final labels = {
      TaskFilter.all: 'All',
      TaskFilter.pending: 'Pending',
      TaskFilter.completed: 'Completed',
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: TaskFilter.values.map((filter) {
          final isSelected = _filter == filter;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${labels[filter]} ${counts[filter]}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    final tasks = _filteredTasks;

    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            _filter == TaskFilter.pending
                ? 'No pending tasks 🎉'
                : 'No completed tasks yet',
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      children: tasks
          .map(
            (task) => _TaskCard(
              task: task,
              onEdit: () => _openEditTask(task),
              onDelete: () => _confirmDelete(task),
              onPriorityChanged: (priority) => _changePriority(task, priority),
            ),
          )
          .toList(),
    );
  }

  // Shown when the selected child has no tasks yet
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: lightPurple,
              shape: BoxShape.circle,
            ),
            child: Text(
              _selectedChild!.avatar,
              style: const TextStyle(fontSize: 56),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'A little task, a big adventure!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedChild!.name} has no tasks yet. Add a first mission '
            'and let the star collecting begin!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAddTask,
              icon: const Icon(Icons.add),
              label: const Text('Add First Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Start small — like making the bed ⭐',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Shown when the parent has not added any children
  Widget _buildNoChildren() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Text('👶', style: TextStyle(fontSize: 48)),
          SizedBox(height: 14),
          Text(
            'Add a child first',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Go to Home and add a child, then you can give them tasks.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// One of the two summary boxes (Pending / Completed)
class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final int count;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

// One task in the list
class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onPriorityChanged,
  });

  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<TaskPriority> onPriorityChanged;

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.high:
        return const Color(0xFFE5484D);
      case TaskPriority.normal:
        return const Color(0xFF7563E8);
      case TaskPriority.low:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3F5)),
      ),
      child: Column(
        children: [
          _buildDetails(),
          const Divider(height: 24, color: Color(0xFFF0EDF8)),
          _buildActions(),
        ],
      ),
    );
  }

  // Edit · Delete · Prioritize row at the bottom of the card
  Widget _buildActions() {
    const purple = Color(0xFF7563E8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit'),
          style: TextButton.styleFrom(foregroundColor: purple),
        ),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
        PopupMenuButton<TaskPriority>(
          onSelected: onPriorityChanged,
          itemBuilder: (context) => TaskPriority.values
              .map(
                (priority) => CheckedPopupMenuItem<TaskPriority>(
                  value: priority,
                  checked: priority == task.priority,
                  child: Text(priority.label),
                ),
              )
              .toList(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 18, color: purple),
                SizedBox(width: 6),
                Text(
                  'Prioritize',
                  style: TextStyle(color: purple, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Icon, title, stars, priority, due date and status
  Widget _buildDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(task.icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + stars
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted
                            ? Colors.grey
                            : const Color(0xFF29283A),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4D6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ ${task.stars}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Priority, due date and status
              Row(
                children: [
                  Icon(Icons.flag, size: 16, color: _priorityColor),
                  const SizedBox(width: 4),
                  Text(
                    task.priority.label,
                    style: TextStyle(
                      color: _priorityColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '  ·  Due ${task.dueLabel}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (task.recurrence != TaskRecurrence.never) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.repeat, size: 14, color: Colors.grey),
                  ],
                  const Spacer(),
                  _StatusChip(isCompleted: task.isCompleted),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Small "Pending" / "Completed" label
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE6F6EC) : const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? '✓ Completed' : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCompleted
              ? const Color(0xFF2E9E5B)
              : const Color(0xFFB7791F),
        ),
      ),
    );
  }
}

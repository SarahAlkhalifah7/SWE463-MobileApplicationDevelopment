import 'package:flutter/material.dart';

import '../models/child.dart';
import '../models/task.dart';
import '../services/task_storage.dart';

// One screen for both adding a new task and editing an existing one.
// If [task] is null we are adding, otherwise we are editing.
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({
    super.key,
    required this.children,
    required this.selectedChild,
    this.task,
  });

  final List<Child> children;
  final Child selectedChild;
  final Task? task;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  static const Color purple = Color(0xFF7563E8);
  static const Color darkText = Color(0xFF29283A);
  static const Color border = Color(0xFFE8E3F5);
  static const Color lightPurple = Color(0xFFF2EFFF);

  // Emojis the parent can choose for a task
  static const List<String> taskIcons = [
    '📝', '📚', '🧹', '🛏️', '🦷', '🎒',
    '🧸', '🍽️', '🚿', '🐶', '🌱', '🎹',
  ];

  // Short names for weekdays (index 0 = Monday = weekday 1)
  static const List<String> weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _starsController = TextEditingController();

  late String _childId;
  String _icon = taskIcons.first;
  TaskPriority _priority = TaskPriority.normal;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskRecurrence _recurrence = TaskRecurrence.never;
  List<int> _customDays = [];

  bool _isSaving = false;
  String? _customDaysError;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    if (task == null) {
      // Adding: start with the child that was selected on the Tasks screen
      _childId = widget.selectedChild.accessCode;
    } else {
      // Editing: fill the form with the task's current values
      _childId = task.childId;
      _titleController.text = task.title;
      _starsController.text = task.stars.toString();
      _icon = task.icon;
      _priority = task.priority;
      _recurrence = task.recurrence;
      _customDays = List<int>.from(task.customDays);

      if (task.dueDate != null) {
        _dueDate = task.dueDate;

        // Midnight means the parent did not choose a time
        if (task.dueDate!.hour != 0 || task.dueDate!.minute != 0) {
          _dueTime = TimeOfDay.fromDateTime(task.dueDate!);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // When editing an old task, its date may be before today
    final firstDate = _dueDate != null && _dueDate!.isBefore(today)
        ? _dueDate!
        : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: firstDate,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? const TimeOfDay(hour: 16, minute: 0),
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  // Combine the chosen date and time into one DateTime
  DateTime? get _fullDueDate {
    if (_dueDate == null) return null;

    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime?.hour ?? 0,
      _dueTime?.minute ?? 0,
    );
  }

  Future<void> _save() async {
    // Custom repeat needs at least one day
    setState(() {
      _customDaysError =
          _recurrence == TaskRecurrence.custom && _customDays.isEmpty
          ? 'Choose at least one day'
          : null;
    });

    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || _customDaysError != null) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final stars = int.parse(_starsController.text.trim());
    final customDays = _recurrence == TaskRecurrence.custom
        ? (_customDays..sort())
        : <int>[];

    if (_isEditing) {
      final updatedTask = widget.task!.copyWith(
        childId: _childId,
        title: title,
        icon: _icon,
        stars: stars,
        priority: _priority,
        dueDate: _fullDueDate,
        clearDueDate: _fullDueDate == null,
        recurrence: _recurrence,
        customDays: customDays,
      );

      await TaskStorage.updateTask(updatedTask);
    } else {
      final newTask = Task(
        id: TaskStorage.generateId(),
        childId: _childId,
        title: title,
        icon: _icon,
        stars: stars,
        priority: _priority,
        dueDate: _fullDueDate,
        recurrence: _recurrence,
        customDays: customDays,
      );

      await TaskStorage.addTask(newTask);
    }

    if (!mounted) return;

    // true tells the Tasks screen to reload its list
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9F0),
        title: Text(
          _isEditing ? 'Edit Task' : 'Add Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard([
                    _label('Task name'),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 40,
                      decoration: _inputDecoration('Enter task name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _label('Icon'),
                    _buildIconPicker(),
                    const SizedBox(height: 18),
                    _label('Child'),
                    DropdownButtonFormField<String>(
                      initialValue: _childId,
                      decoration: _inputDecoration('Select a child'),
                      items: widget.children
                          .map(
                            (child) => DropdownMenuItem(
                              value: child.accessCode,
                              child: Text('${child.avatar}  ${child.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _childId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select a child' : null,
                    ),
                    const SizedBox(height: 18),
                    _label('Star reward amount'),
                    TextFormField(
                      controller: _starsController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration('Enter amount').copyWith(
                        prefixIcon: const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF5B82E),
                        ),
                        suffixText: 'stars',
                      ),
                      validator: (value) {
                        final stars = int.tryParse(value?.trim() ?? '');

                        if (stars == null) {
                          return 'Please enter a number of stars';
                        }
                        if (stars < 1 || stars > 100) {
                          return 'Stars must be between 1 and 100';
                        }
                        return null;
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard([
                    _label('Priority'),
                    _buildOptions<TaskPriority>(
                      values: TaskPriority.values,
                      selected: _priority,
                      labelOf: (p) => p.label,
                      onSelected: (p) => setState(() => _priority = p),
                    ),
                    const SizedBox(height: 18),
                    _label('Due day / date'),
                    _buildDueDatePicker(),
                    const SizedBox(height: 18),
                    _label('Recurrence'),
                    _buildOptions<TaskRecurrence>(
                      values: TaskRecurrence.values,
                      selected: _recurrence,
                      labelOf: (r) => r.label,
                      onSelected: (r) => setState(() {
                        _recurrence = r;
                        _customDaysError = null;
                      }),
                    ),
                    if (_recurrence == TaskRecurrence.custom) ...[
                      const SizedBox(height: 12),
                      _buildWeekdayPicker(),
                    ],
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _isEditing ? 'Save Changes' : 'Add Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: purple),
                      ),
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

  // White rounded card that groups form fields
  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: darkText),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: taskIcons.map((icon) {
        final isSelected = icon == _icon;

        return GestureDetector(
          onTap: () => setState(() => _icon = icon),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? lightPurple : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? purple : border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }

  // A row of buttons where one can be selected (used for priority and repeat)
  Widget _buildOptions<T>({
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required ValueChanged<T> onSelected,
  }) {
    return Row(
      children: values.map((value) {
        final isSelected = value == selected;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelected(value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? purple : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? purple : border),
                ),
                child: Text(
                  labelOf(value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDueDatePicker() {
    final dateText = _dueDate == null
        ? 'Anytime (no due date)'
        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(dateText),
                style: _pickerButtonStyle(),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                onPressed: () => setState(() {
                  _dueDate = null;
                  _dueTime = null;
                }),
                icon: const Icon(Icons.close, color: Colors.grey),
                tooltip: 'Remove due date',
              ),
          ],
        ),
        if (_dueDate != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(
                    _dueTime == null
                        ? 'Add a time (optional)'
                        : _dueTime!.format(context),
                  ),
                  style: _pickerButtonStyle(),
                ),
              ),
              if (_dueTime != null)
                IconButton(
                  onPressed: () => setState(() => _dueTime = null),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  tooltip: 'Remove time',
                ),
            ],
          ),
        ],
      ],
    );
  }

  ButtonStyle _pickerButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: darkText,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      side: const BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Mon ... Sun chips, shown only for custom repeat
  Widget _buildWeekdayPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(7, (index) {
            final weekday = index + 1;
            final isSelected = _customDays.contains(weekday);

            return FilterChip(
              label: Text(weekdayNames[index]),
              selected: isSelected,
              selectedColor: lightPurple,
              checkmarkColor: purple,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _customDays.add(weekday);
                  } else {
                    _customDays.remove(weekday);
                  }
                  _customDaysError = null;
                });
              },
            );
          }),
        ),
        if (_customDaysError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _customDaysError!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

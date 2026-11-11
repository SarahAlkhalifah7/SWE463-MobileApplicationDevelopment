import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  static const String _tasksKey = 'tasks';

  // Create a unique id for a new task (based on the current time)
  static String generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  // Get all saved tasks (for all children)
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final tasksData = prefs.getStringList(_tasksKey) ?? [];

    return tasksData.map((taskString) {
      final Map<String, dynamic> data = jsonDecode(taskString);

      return Task.fromJson(data);
    }).toList();
  }

  // Get the tasks of one child only
  static Future<List<Task>> getTasksForChild(String childId) async {
    final tasks = await getTasks();

    return tasks.where((task) => task.childId == childId).toList();
  }

  // Save all tasks
  static Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();

    final tasksData = tasks.map((task) => jsonEncode(task.toJson())).toList();

    await prefs.setStringList(_tasksKey, tasksData);
  }

  // Add a new task
  static Future<void> addTask(Task task) async {
    final tasks = await getTasks();

    tasks.add(task);

    await _saveTasks(tasks);
  }

  // Replace an existing task (found by id) with the updated version
  static Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();

    final index = tasks.indexWhere((task) => task.id == updatedTask.id);

    if (index != -1) {
      tasks[index] = updatedTask;

      await _saveTasks(tasks);
    }
  }

  // Delete one task
  static Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();

    tasks.removeWhere((task) => task.id == taskId);

    await _saveTasks(tasks);
  }

  // Delete all tasks of a child (used when the child is removed)
  static Future<void> deleteTasksForChild(String childId) async {
    final tasks = await getTasks();

    tasks.removeWhere((task) => task.childId == childId);

    await _saveTasks(tasks);
  }
}

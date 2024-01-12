import 'package:flutter/material.dart';
import 'package:task_tracker/services/task.dart';
import 'package:task_tracker/services/shared_preferences_service.dart';

class TaskData extends ChangeNotifier {
  List<Task> tasks = [];

  void addTask(String taskName, DateTime? dueDate) {
    final task = Task(name: taskName, dueDate: dueDate);
    tasks.add(task);
    notifyListeners();
    saveTasksToSharedPreferences();
  }

  void updateTask(Task task, {DateTime? dueDate}) {
    task.toggleDone();
    if (dueDate != null) {
      task.dueDate = dueDate;
    }
    notifyListeners();
    saveTasksToSharedPreferences();
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    notifyListeners();
    saveTasksToSharedPreferences();
  }

  void saveTasksToSharedPreferences() {
    SharedPreferencesService.saveTasks(tasks);
  }

  void setTasks(List<Task> newTasks) {
    tasks = newTasks;
    notifyListeners();
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1; // Adjust the index if the item is moving down the list
    }

    Task movedTask = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, movedTask);
    saveTasksToSharedPreferences();
    notifyListeners();
  }

  void sortTasksByDueDate() {
    tasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return 0; // If both tasks have no due date, leave them unchanged
      } else if (a.dueDate == null) {
        return 1; // If only task a has no due date, move it to the bottom
      } else if (b.dueDate == null) {
        return -1; // If only task b has no due date, move it to the bottom
      } else {
        return a.dueDate!.compareTo(b.dueDate!); // Sort by due date
      }
    });

    notifyListeners();
    saveTasksToSharedPreferences();
  }
}

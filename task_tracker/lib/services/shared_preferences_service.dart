import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_tracker/services/task.dart';

class SharedPreferencesService {
  static late SharedPreferences _sp;

  static Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  static void saveTasks(List<Task> tasks) {
    List<String> taskListString = tasks.map((task) {
      Map<String, dynamic> taskMap = {
        'name': task.name,
        'isDone': task.isDone,
        'dueDate': task.dueDate?.toIso8601String(),
      };
      return jsonEncode(taskMap);
    }).toList();
    _sp.setStringList('myData', taskListString);
  }

  static List<Task> readTasks() {
    List<String>? taskListString = _sp.getStringList('myData');
    if (taskListString != null) {
      return taskListString.map((task) {
        Map<String, dynamic> taskMap = json.decode(task);
        return Task(
          name: taskMap['name'],
          isDone: taskMap['isDone'],
          dueDate: taskMap['dueDate'] != null
              ? DateTime.parse(taskMap['dueDate'])
              : null,
        );
      }).toList();
    } else {
      return [];
    }
  }

  static void updateTask(Task task) {
    List<Task> tasks = readTasks();
    int index = tasks.indexWhere((t) => t.name == task.name);
    if (index != -1) {
      tasks[index] = task;
      saveTasks(tasks);
    }
  }
}

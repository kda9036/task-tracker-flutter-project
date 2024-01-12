import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/modals/add_task_screen.dart';
import 'package:task_tracker/services/task.dart';
import 'package:task_tracker/services/task_data.dart';
import 'package:task_tracker/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:task_tracker/services/theme_service.dart';
import 'package:google_fonts/google_fonts.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
  }

  _initializeSharedPreferences() async {
    await SharedPreferencesService.init();
    _readData();
  }

  _readData() {
    List<Task> tasks = SharedPreferencesService.readTasks();
    Provider.of<TaskData>(context, listen: false).setTasks(tasks);
  }

  _saveData() {
    List<Task> tasks = Provider.of<TaskData>(context, listen: false).tasks;
    SharedPreferencesService.saveTasks(tasks);
  }

  _updateTask(Task task) {
    Provider.of<TaskData>(context, listen: false).updateTask(task);
    SharedPreferencesService.updateTask(task);
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      backgroundColor: themeService.getThemeColor(),
      // Button to add task
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return AddTaskScreen(onSave: () {
                  _saveData();
                });
              });
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title, and task sort option
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.task,
                      size: 40.0,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tasks",
                            style: GoogleFonts.merriweather(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        Text(
                          "${Provider.of<TaskData>(context).tasks.where((task) => !task.isDone).length} Todo",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        )
                      ],
                    ),
                  ),
                  // Sort tasks
                  IconButton(
                    icon: const Icon(Icons.sort),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () {
                      Provider.of<TaskData>(context, listen: false)
                          .sortTasksByDueDate();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                color: Colors.white,
                child: Consumer<TaskData>(
                  builder: (context, taskData, child) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      // List all tasks
                      child: ReorderableListView(
                        children: taskData.tasks
                            .asMap()
                            .entries
                            .map(
                              (entry) => CustomTaskTile(
                                key: Key(entry.value.name),
                                context: context,
                                task: entry.value,
                                color: color,
                                onChanged: (checkbox) {
                                  setState(() {
                                    taskData.updateTask(entry.value);
                                  });
                                  // Update SharedPreferences
                                  _updateTask(entry.value);
                                },
                                onDelete: () {
                                  taskData.deleteTask(entry.value);
                                },
                              ),
                            )
                            .toList(),
                        onReorder: (oldIndex, newIndex) {
                          taskData.reorderTasks(oldIndex, newIndex);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tiles for tasks
class CustomTaskTile extends StatelessWidget {
  final BuildContext context;
  final Task task;
  final Color color;
  final Function(bool?) onChanged;
  final Function() onDelete;

  const CustomTaskTile({
    super.key,
    required this.context,
    required this.task,
    required this.color,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(task.name),
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: color, width: 1.0),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                task.name,
                style: TextStyle(
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            // Due date (optional)
            if (task.dueDate != null)
              Text(
                _formattedDueDate(task.dueDate!),
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        // Checkbox state based on isDone bool
        leading: Checkbox(
          activeColor: color,
          value: task.isDone,
          onChanged: (checkbox) {
            _updateTask(task);
            onChanged(checkbox);
          },
        ),
        // 'X' to delete task
        trailing: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _formattedDueDate(DateTime dueDate) {
    return DateFormat('yyyy-MM-dd').format(dueDate);
  }

  void _updateTask(Task task) {
    Provider.of<TaskData>(context, listen: false).updateTask(task);
    SharedPreferencesService.updateTask(task);
  }
}

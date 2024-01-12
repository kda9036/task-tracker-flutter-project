import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_tracker/modals/add_task_screen.dart';
import 'package:task_tracker/services/task.dart';
import 'package:task_tracker/services/task_data.dart';
import 'package:task_tracker/services/shared_preferences_service.dart';
import 'package:task_tracker/services/theme_service.dart';
import 'package:google_fonts/google_fonts.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _events = {};
  List<Task> _tasks = [];

  List<Task> _getEventsForDay(DateTime day) {
    DateTime dateWithoutTime = DateTime(day.year, day.month, day.day);
    return _events[dateWithoutTime] ?? [];
  }

  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    _loadTasks();
    _selectedDay = null;
  }

  Future<void> _loadTasks() async {
    await SharedPreferencesService.init();
    List<Task> tasks = SharedPreferencesService.readTasks();
    setState(() {
      // Filter out completed tasks
      _tasks = tasks.where((task) => !task.isDone).toList();
      _events = _getEventsMap();

      // Set initial date to the highlighted date on page load
      _selectedDay = _focusedDay;
    });
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
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      backgroundColor: themeService.getThemeColor(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          // Display add task screen for user input
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
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              // Header with icon and title
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.calendar_month,
                      size: 40.0,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Calendar",
                          style: GoogleFonts.merriweather(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Display number of deadlines (tasks with due dates and isDone false)
                        (Provider.of<TaskData>(context)
                                    .tasks
                                    .where((task) =>
                                        task.dueDate != null && !task.isDone)
                                    .length ==
                                1)
                            ? Text(
                                "${Provider.of<TaskData>(context).tasks.where((task) => task.dueDate != null && !task.isDone).length} Deadline",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              )
                            : Text(
                                "${Provider.of<TaskData>(context).tasks.where((task) => task.dueDate != null && !task.isDone).length} Deadlines",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                ),
                              ),
                      ],
                    ),
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
                    return content();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ListView(
        children: [
          // Calendar
          TableCalendar(
            key: Key(_selectedDay.toString()),
            calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                )),
            calendarFormat: _calendarFormat,
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (DateTime day) {
              // Check if the day matches the selected day
              return isSameDay(day, _selectedDay);
            },
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 11, 22),
            lastDay: DateTime.utc(2030, 11, 22), // Random date in future
            eventLoader: _getEventsForDay,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(
                    selectedDay.year, selectedDay.month, selectedDay.day);
                _focusedDay = focusedDay;
                _updateTasksForSelectedDay();
              });
            },
          ),
          const SizedBox(height: 20.0),
          // Title including date selected to display tasks with due dates for that date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tasks for ${_selectedDay.toString().split(" ")[0]}",
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.drag_handle) // Indicate can drag up if task list too long
            ],
          ),
          // Check tasks and add to list if due date matches selected day
          ListView.builder(
            shrinkWrap: true,
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              // Check if the task's due date matches the selected day
              if (isSameDay(_tasks[index].dueDate ?? DateTime(2000),
                  _selectedDay ?? DateTime(2000))) {
                return ListTile(
                  title: Text(_tasks[index].name),
                );
              } else {
                // Return an empty container for tasks not matching the selected day
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Task>> _getEventsMap() {
    Map<DateTime, List<Task>> eventsMap = {};
    for (Task task in _tasks) {
      DateTime date = task.dueDate ??
          DateTime(2000); // Use a default date if dueDate is null
      if (eventsMap.containsKey(date)) {
        eventsMap[date]!.add(task);
      } else {
        eventsMap[date] = [task];
      }
    }
    return eventsMap;
  }

  void _updateTasksForSelectedDay() {
    if (_selectedDay == null) {
      // Show tasks for the initially highlighted date
      setState(() {
        _tasks = _getEventsForDay(_focusedDay)
            .where((task) => !task.isDone)
            .toList();
      });
    } else {
      DateTime selectedDayWithoutTime =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);

      setState(() {
        // Filter out completed tasks for the selected day
        _tasks = _getEventsForDay(selectedDayWithoutTime)
            .where((task) => !task.isDone)
            .toList();
      });
    }
  }
}

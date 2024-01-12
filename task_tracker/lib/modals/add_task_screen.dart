import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/services/task_data.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  final Null Function() onSave;
  const AddTaskScreen({super.key, required this.onSave});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  String taskName = "";
  DateTime? dueDate;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Add Task",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.0,
              color: color,
            ),
          ),
          TextField(
            autofocus: true,
            onChanged: (val) {
              taskName = val;
            },
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Text(
                'Due Date (optional): ',
                style: TextStyle(color: color),
              ),
              ElevatedButton(
                onPressed: () => _selectDueDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .primaryColor, // Use your theme's primary color here
                ),
                child: Text(
                  dueDate == null
                      ? 'Select Due Date'
                      : DateFormat('yyyy-MM-dd').format(dueDate!),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: color),
            onPressed: () {
              if (taskName.isNotEmpty) {
                Provider.of<TaskData>(context, listen: false)
                    .addTask(taskName, dueDate);
                widget.onSave();
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }
}

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:task_tracker/pages/tasks.dart';
import 'package:task_tracker/pages/calendar.dart';
import 'package:task_tracker/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:task_tracker/services/task_data.dart';
import 'package:task_tracker/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(
    MultiProvider(
      providers: [
        // Color Theme
        ChangeNotifierProvider<ThemeService>(
          create: (context) => ThemeService(),
        ),
        // Task Data
        ChangeNotifierProvider<TaskData>(
          create: (context) => TaskData(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
        // set color theme
        colorScheme:
            ColorScheme.fromSeed(seedColor: themeService.getThemeColor()),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const Home(), const Tasks(), const Calendar()];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:task_tracker/services/quote.dart';
import 'package:task_tracker/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String quote = "Loading";
  String author = "Loading";
  bool _mounted = false;

  void setupQuote() async {
    Quote instance = Quote();
    await instance.getQuote();

    if (_mounted) {
      setState(() {
        quote = instance.quote;
        author = instance.author;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;
    setupQuote();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return Scaffold(
      backgroundColor: themeService.getThemeColor(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              // Header with icon, title, and settings option
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.list,
                      size: 40.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Task Tracker",
                          style: GoogleFonts.merriweather(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings icon - click to display color picker and choose theme color
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    iconSize: 40.0,
                    onPressed: () async {
                      Color? selectedColor = await showDialog<Color>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select Theme Color'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: themeService.getThemeColor(),
                                onColorChanged: (color) {
                                  // Handle color changes in real-time
                                  themeService.setThemeColor(color);
                                },
                                pickerAreaHeightPercent: 0.8,
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(themeService.getThemeColor());
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (selectedColor != null) {
                        themeService.setThemeColor(selectedColor);
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  // Background image
                  image: DecorationImage(
                    image: AssetImage("assets/unsplash_space.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  // Display quote on card
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    color: Theme.of(context).colorScheme.inversePrimary,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // Card can take up height of its container
                        children: <Widget>[
                          Text('"$quote"',
                              style: const TextStyle(
                                fontSize: 24.0,
                                color: Colors.black,
                              )),
                          const SizedBox(height: 10.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '- $author',
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

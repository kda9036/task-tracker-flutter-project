import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  static late SharedPreferences _sp;

  // Key for storing the theme color in shared preferences
  static const String themeColorKey = 'themeColor';

  // Default theme color
  static const Color defaultThemeColor = Colors.blue;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  // Get the current theme color
  Color getThemeColor() {
    dynamic storedColor = _sp.get(themeColorKey);

    // Check if storedColor is null or not a valid string representation of an int
    if (storedColor == null ||
        (storedColor is! String && storedColor is! int) ||
        (storedColor is String && !RegExp(r'^[0-9]+$').hasMatch(storedColor))) {
      return defaultThemeColor;
    }

    return Color(storedColor is String ? int.parse(storedColor) : storedColor);
  }

  // Set and store the new theme color
  void setThemeColor(Color color) {
    _sp.setString(themeColorKey, color.value.toString());
    notifyListeners(); // Notify listeners about the change
  }
}

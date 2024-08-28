import 'package:flutter/material.dart';
import 'package:habbit_tracker/themes/dark_mode.dart';

import 'light_mode.dart';


class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode; 

  bool get isLightMode => _themeData == lightMode; 

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = isDarkMode ? lightMode : darkMode;
    notifyListeners();
  }
}
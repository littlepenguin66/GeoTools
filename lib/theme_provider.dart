import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme;
  ThemeData get currentTheme => _currentTheme;

  ThemeProvider({required bool isDarkMode})
      : _currentTheme = isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    if (_currentTheme == lightTheme) {
      _currentTheme = darkTheme;
    } else {
      _currentTheme = lightTheme;
    }
    notifyListeners();
  }

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.grey,
    brightness: Brightness.light,
    iconTheme: const IconThemeData(color: Colors.black),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'CustomFont'),
      bodyMedium: TextStyle(fontFamily: 'CustomFont'),
      displayLarge: TextStyle(fontFamily: 'CustomFont'),
      displayMedium: TextStyle(fontFamily: 'CustomFont'),
      displaySmall: TextStyle(fontFamily: 'CustomFont'),
      headlineMedium: TextStyle(fontFamily: 'CustomFont'),
      headlineSmall: TextStyle(fontFamily: 'CustomFont'),
      titleLarge: TextStyle(fontFamily: 'CustomFont'),
    ).apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontFamily: 'CustomFont'),
      bodyMedium: TextStyle(fontFamily: 'CustomFont'),
      displayLarge: TextStyle(fontFamily: 'CustomFont'),
      displayMedium: TextStyle(fontFamily: 'CustomFont'),
      displaySmall: TextStyle(fontFamily: 'CustomFont'),
      headlineMedium: TextStyle(fontFamily: 'CustomFont'),
      headlineSmall: TextStyle(fontFamily: 'CustomFont'),
      titleLarge: TextStyle(fontFamily: 'CustomFont'),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
import 'package:flutter/material.dart';

/// Creates a theme with the specified brightness and seed color
ThemeData createTheme(Brightness brightness, {Color seedColor = Colors.blue}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: brightness == Brightness.light
        ? Colors.white
        : Colors.grey[900],
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Light theme configuration
ThemeData get lightTheme => createTheme(Brightness.light);

/// Dark theme configuration
ThemeData get darkTheme => createTheme(Brightness.dark);

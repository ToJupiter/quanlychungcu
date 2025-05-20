import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black, // For text primarily
    colorScheme: const ColorScheme.light(
      primary: Colors.black, // Text, icons against primary background
      onPrimary: Colors.white, // Text on primary-colored elements (e.g., buttons)
      secondary: Color(0xFFFFC0CB), // Light Pink - accent/highlight
      onSecondary: Colors.black, // Text/icons on accent-colored elements
      surface: Colors.white, // Card backgrounds, dialogs
      onSurface: Colors.black, // Text on cards, dialogs
      background: Colors.white, // General background
      onBackground: Colors.black, // Text on general background
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      // Define specific text styles if needed, otherwise Material defaults will be used.
      // Example:
      // displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: Colors.black),
      // titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.black),
      // bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Roboto', color: Colors.black),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFFFFC0CB), // Light Pink for buttons
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC0CB), // Light Pink for FilledButton
        foregroundColor: Colors.black, // Text color for FilledButton
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFFC0CB), // Light Pink for TextButton text
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0, // Minimalist app bar
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFC0CB), width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      // Define other properties like labelStyle, hintStyle if needed
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFFFC0CB), // Default icon color: Light Pink
    ),
    // Use a font compatible with Arial if Roboto is not desired (Roboto is Material default)
    // fontFamily: 'YourCustomFont', // Ensure font is added to pubspec.yaml
  );
} 
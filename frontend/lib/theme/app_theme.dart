import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color.fromRGBO(130, 115, 84, 1);
  static const secondaryColor = Color.fromRGBO(245, 225, 184, 1);
  static const backgroundColor = Color.fromRGBO(252, 245, 237, 1);
  static const whiteColor = Color.fromRGBO(255, 255, 255, 1);
  static const disabledColor = Color.fromRGBO(177, 177, 177, 1);
  static const textColor = Color.fromRGBO(130, 115, 84, 1);
  static const purpleColor = Color.fromRGBO(61, 0, 102, 1);
  
  static final lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Pangolin',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Sigmar Cyrillic', fontSize: 128),
      headlineMedium: TextStyle(fontFamily: 'Sigmar Cyrillic', fontSize: 64),
      titleLarge: TextStyle(fontFamily: 'Sigmar Cyrillic', fontSize: 32),
      titleMedium: TextStyle(fontFamily: 'Sigmar Cyrillic', fontSize: 20),
      bodyLarge: TextStyle(fontFamily: 'Pangolin', fontSize: 32),
      bodyMedium: TextStyle(fontFamily: 'Pangolin', fontSize: 20),
      bodySmall: TextStyle(fontFamily: 'Pangolin', fontSize: 16),
    ),
  );
}
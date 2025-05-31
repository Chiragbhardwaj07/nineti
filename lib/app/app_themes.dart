import 'package:flutter/material.dart';

class AppTheme {
  static const _fontFamily = 'Lato';

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.indigo,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 40,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w900,
        color: Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: _fontFamily,
        color: Colors.black,
        letterSpacing: 0.3,
        height: 1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 14,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 12,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.blueGrey,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 40,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      headlineSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: _fontFamily,
        color: Colors.white,
        letterSpacing: 0.3,
        height: 1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 14,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 12,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    ),
  );
}

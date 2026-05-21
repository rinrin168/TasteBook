import 'package:flutter/material.dart';

class TasteBookColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFFFDFB);
  static const Color sand = Color(0xFFDACABD);
  static const Color tan = Color(0xFFBFA693);
  static const Color cocoa = Color(0xFF4C382A);
  static const Color espresso = Color(0xFF514135);
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TasteBookColors.tan,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: TasteBookColors.tan,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

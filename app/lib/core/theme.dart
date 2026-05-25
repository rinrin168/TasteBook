import 'package:flutter/material.dart';

class TasteBookColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFFAF8F5); // Premium warm off-white background
  static const Color sand = Color(0xFFEADFD8); // Soft beige outline
  static const Color tan = Color(0xFFF5EFEB); // Light warm beige
  static const Color cocoa = Color(0xFF4A3525); // Deep Cocoa/Espresso primary
  static const Color espresso = Color(0xFF2C1E17); // Rich dark charcoal text
}

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: TasteBookColors.cocoa,
      brightness: Brightness.light,
      primary: TasteBookColors.cocoa,
      surface: TasteBookColors.cream,
    ),
    scaffoldBackgroundColor: TasteBookColors.cream,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: TasteBookColors.espresso),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TasteBookColors.espresso),
      bodyMedium: TextStyle(fontSize: 14, color: TasteBookColors.espresso),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TasteBookColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TasteBookColors.sand, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TasteBookColors.sand, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: TasteBookColors.cocoa, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

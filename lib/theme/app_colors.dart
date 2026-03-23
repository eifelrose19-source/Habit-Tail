import 'package:flutter/material.dart';

/// Centralized color palette for HabitTail.
/// Import this file instead of re-declaring colors in each screen.
class AppColors {
  AppColors._(); // prevent instantiation

  static const Color softIris = Color(0xFFD0BFFF);      // Primary Background
  static const Color blushPink = Color(0xFFFFADBC);      // Secondary
  static const Color electricSky = Color(0xFF98E4FF);    // Button / Accent
  static const Color pureWhite = Color(0xFFFFFFFF);      // Surface
  static const Color midnightPlum = Color(0xFF3F2E5A);   // Deep Text
  static const Color gradientEnd = Color(0xFFE0D4FC);    // Gradient bottom
}

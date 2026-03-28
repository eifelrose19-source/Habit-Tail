import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(); 

  //Color Palette
  static const Color softIris    = Color(0xFFD0BFFF); // Primary Background
  static const Color electricSky = Color(0xFF98E4FF); // Button Background
  static const Color midnightPlum = Color(0xFF3F2E5A); // Text Color
  static const Color irisLight   = Color(0xFFE0D4FC); // Gradient End
  // Background Colors
static const Color beigeBackground = Color(0xFFF0EAD6); // Dashboard background
  //Background Gradient
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [softIris, irisLight],
    ),
  );
  // Button Style
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: electricSky,
    foregroundColor: midnightPlum,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
  //Text Styles
  static TextStyle bodyText({double fontSize = 14, FontWeight fontWeight = FontWeight.w500}) =>
    GoogleFonts.quicksand(fontSize: fontSize, fontWeight: fontWeight, color: midnightPlum);

  static TextStyle buttonText() =>
    GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.bold, color: midnightPlum);

  static TextStyle codeText() =>
    GoogleFonts.quicksand(fontSize: 24, fontWeight: FontWeight.bold, color: midnightPlum, letterSpacing: 2);
  
  // Code Display Box
  static BoxDecoration codeBoxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: midnightPlum.withAlpha((0.1 * 255).round()),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

//Reusable Button Widget
static Widget buildButton({
  required BuildContext context,
  required String label,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: onTap,
      style: elevatedButtonStyle,
      child: Text(label, style: buttonText()),
    ),
  );
}

//Reusable Screen Scaffold wraps screen in standard HabitTail gradient background + safe area + horizontal padding
static Widget screenWrapper({required Widget child}) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: backgroundGradient,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: child,
        ),
      ),
    ),
  );
}
}
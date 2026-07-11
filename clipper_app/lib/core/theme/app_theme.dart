import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF22D3EE), // Cyan accent
        secondary: Color(0xFF8B5CF6), // Violet
        surface: Color(0xFF1A1A22), // Surface
        background: Color(0xFF0F0F12),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F12),
      // textTheme: GoogleFonts.interTextTheme(
      //   ThemeData(brightness: Brightness.dark).textTheme,
      // ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F0F12),
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(0xFF00FFCC),
        unselectedItemColor: Colors.white54,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFCC),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xFF00FFCC),
        inactiveTrackColor: Colors.white24,
        thumbColor: Color(0xFF00FFCC),
      ),
    );
  }
}

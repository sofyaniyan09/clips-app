import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F0F12);
  static const Color surface = Color(0xFF1A1A22);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color primary = violet;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [violet, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

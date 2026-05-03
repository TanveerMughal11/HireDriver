import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF756BB1);
  static const Color secondary = Color(0xFFBCBDDC);
  static const Color light = Color(0xFFEFE0F5);
  static const Color darkPrimary = Color(0xFF4B3F99);

  static const Color textPrimary = Color(0xFF0D1321);
  static const Color textSecondary = Color(0xFF4E5D78);

  static const Color background = Color(0xFFEFE0F5);

  static const Color white = Colors.white;
  static const Color grey = Color(0xFFD0D4DD);

  // DARK MODE COLORS
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  static Color bg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : background;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : white;
  }

  static Color text1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color text2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }

  static Color softBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : light;
  }
}
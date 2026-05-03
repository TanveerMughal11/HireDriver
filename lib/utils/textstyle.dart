import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hire_driver/utils/app_colors.dart';

class AppTextStyles {
  static final TextStyle introTitle = GoogleFonts.poppins(
    fontSize: 36,
    height: 1,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static final TextStyle introDescription = GoogleFonts.poppins(
    fontSize: 14,
    height: 1.6,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle tagText(Color color) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle chipText(Color color) => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static final TextStyle splashTitle = GoogleFonts.poppins(
    fontSize: 42,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    color: Colors.white,
  );
}
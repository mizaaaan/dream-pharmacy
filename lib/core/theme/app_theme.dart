import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class AppColors {
  static const red = Color(0xFFE2231A);
  static const redDark = Color(0xFFB81811);
  static const ink = Color(0xFF33363F);
  static const inkSoft = Color(0xFF5B5F6B);
  static const teal = Color(0xFF2CA89C);
  static const navy = Color(0xFF1F3A63);
  static const amber = Color(0xFFC98A2B);
  static const paper = Color(0xFFFFFFFF);
  static const band = Color(0xFFECEEF4);
  static const line = Color(0xFFD3D2CC);
}
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        primary: AppColors.red,
        secondary: AppColors.teal,
        surface: AppColors.paper,
      ),
      textTheme: GoogleFonts.hindTextTheme().copyWith(
        headlineLarge: GoogleFonts.barlowCondensed(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.barlowCondensed(
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.hind(color: AppColors.ink),
        bodyMedium: GoogleFonts.hind(color: AppColors.inkSoft),
      ),
    );
  }
}

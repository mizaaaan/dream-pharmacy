import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dream Pharmacy brand kit.
/// Colors pulled directly from the shop logo / signboard / business card
/// so the app matches the physical store and the existing website.
class AppColors {
  AppColors._();

  static const red = Color(0xFFE2231A); // primary — cross + wordmark
  static const redDark = Color(0xFFB81811);
  static const navy = Color(0xFF1F3A63); // capsule navy
  static const teal = Color(0xFF2CA89C); // capsule teal
  static const ink = Color(0xFF33363F); // stethoscope charcoal — body text
  static const inkSoft = Color(0xFF5B5F6B);
  static const amber = Color(0xFFC98A2B); // warm accent — Rx tag, warnings
  static const paper = Color(0xFFFFFFFF);
  static const band = Color(0xFFECEEF4); // soft section background
  static const line = Color(0xFFD3D2CC); // borders / dividers
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.red,
      onPrimary: AppColors.paper,
      secondary: AppColors.navy,
      onSecondary: AppColors.paper,
      tertiary: AppColors.teal,
      onTertiary: AppColors.paper,
      error: AppColors.redDark,
      onError: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.band,
      outline: AppColors.line,
    );

    final headingFont = GoogleFonts.barlowCondensedTextTheme();
    final bodyFont = GoogleFonts.hindTextTheme();

    final textTheme = bodyFont.copyWith(
      displayLarge: headingFont.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      displayMedium: headingFont.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      headlineLarge: headingFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.ink,
      ),
      headlineMedium: headingFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.ink,
      ),
      headlineSmall: headingFont.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: AppColors.ink,
      ),
      titleLarge: headingFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.ink,
      ),
      titleMedium: bodyFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(color: AppColors.ink),
      bodyMedium: bodyFont.bodyMedium?.copyWith(color: AppColors.ink),
      bodySmall: bodyFont.bodySmall?.copyWith(color: AppColors.inkSoft),
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.band,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.barlowCondensed(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.ink,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),

      cardTheme: CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.line, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.red,
          foregroundColor: AppColors.paper,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.hind(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.red,
          textStyle: GoogleFonts.hind(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.red, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.redDark),
        ),
        labelStyle: const TextStyle(color: AppColors.inkSoft),
        hintStyle: const TextStyle(color: AppColors.inkSoft),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.band,
        selectedColor: AppColors.red,
        labelStyle: GoogleFonts.hind(
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        secondaryLabelStyle: GoogleFonts.hind(
          fontWeight: FontWeight.w600,
          color: AppColors.paper,
        ),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.hind(color: AppColors.paper),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.red,
        foregroundColor: AppColors.paper,
      ),
    );
  }
}

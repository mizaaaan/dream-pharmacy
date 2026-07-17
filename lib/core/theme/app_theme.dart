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
  // Cool neutral border, tuned to sit quietly against `band` instead of
  // clashing with it (previously a warm khaki-gray).
  static const line = Color(0xFFDCE0EA);
}

class AppRadius {
  static const card = 12.0;
  static const control = 10.0;
}

class AppTheme {
  static ThemeData light() {
    final radiusControl = BorderRadius.circular(AppRadius.control);
    final radiusCard = BorderRadius.circular(AppRadius.card);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.band,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        brightness: Brightness.light,
        primary: AppColors.red,
        secondary: AppColors.teal,
        tertiary: AppColors.amber,
        surface: AppColors.paper,
        error: AppColors.redDark,
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
        headlineSmall: GoogleFonts.barlowCondensed(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.barlowCondensed(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.hind(color: AppColors.ink),
        bodyMedium: GoogleFonts.hind(color: AppColors.inkSoft),
        labelLarge: GoogleFonts.hind(fontWeight: FontWeight.w600, color: AppColors.ink),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.barlowCondensed(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: radiusCard,
          side: const BorderSide(color: AppColors.line),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.hind(color: AppColors.inkSoft),
        labelStyle: GoogleFonts.hind(color: AppColors.inkSoft),
        border: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusControl,
          borderSide: const BorderSide(color: AppColors.redDark),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper,
        selectedColor: AppColors.red,
        disabledColor: AppColors.band,
        shape: StadiumBorder(side: const BorderSide(color: AppColors.line)),
        labelStyle: GoogleFonts.hind(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13),
        secondaryLabelStyle: GoogleFonts.hind(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusControl),
          textStyle: GoogleFonts.hind(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: radiusControl),
          textStyle: GoogleFonts.hind(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(borderRadius: radiusControl),
          textStyle: GoogleFonts.hind(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusControl),
          textStyle: GoogleFonts.hind(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.hind(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.inkSoft,
        textColor: AppColors.ink,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.red,
      ),
    );
  }
}

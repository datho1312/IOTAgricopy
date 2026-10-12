// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: AppColors.forestGreen,
    colorScheme: const ColorScheme.light(
      primary: AppColors.forestGreen,
      secondary: AppColors.sage,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.primaryText,
      displayColor: AppColors.primaryText,
    ),
    primaryTextTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.primaryText,
      displayColor: AppColors.primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.primaryText,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.42),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
  );
}

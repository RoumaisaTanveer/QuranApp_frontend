// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const bg         = Color(0xFF17171E);
  static const bg2        = Color(0xFF1E1E28);
  static const bg3        = Color(0xFF252530);
  static const bg4        = Color(0xFF2C2C3A);
  static const card       = Color(0xFF1E1E28);  // alias for bg2

  static const purple      = Color(0xFF7B5CF0);
  static const purpleLight = Color(0xFF9B7BCA);
  static const purpleDim   = Color(0x22785CF0);
  static const purpleGlow  = Color(0x55785CF0);

  static const red         = Color(0xFFE84545);
  static const orange      = Color(0xFFE8944A);
  static const green       = Color(0xFF4FC87A);
  static const blue        = Color(0xFF4A90E2);

  static const gold        = Color(0xFFD4A84B);
  static const goldLight   = Color(0xFFEDC870);
  static const goldDim     = Color(0x18D4A84B);

  static const text        = Color(0xFFEEEEF5);
  static const textSub     = Color(0xFF9090A8);
  static const textDim     = Color(0xFF9090A8);   // alias for textSub
  static const textMuted   = Color(0xFF50505F);

  static const border      = Color(0xFF2E2E3C);
  static const borderLight = Color(0xFF3A3A4C);
  static const borderMid   = Color(0xFF3A3A4C);   // alias for borderLight
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.purple,
      surface: AppColors.card,
      onSurface: AppColors.text,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.text),
    ),
    dividerColor: AppColors.border,
  );
}

class AppText {
  static TextStyle sans({
    double size = 14,
    Color color = AppColors.text,
    FontWeight weight = FontWeight.w400,
    double? spacing,
    double? height,
    bool italic = false,
  }) => TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing ?? (size > 16 ? -0.5 : -0.2),
    height: height ?? 1.45,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  );

  static TextStyle arabic({
    double size = 22,
    Color color = AppColors.goldLight,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: size,
    color: color,
    height: 2.2,
    fontWeight: weight,
  );

  static TextStyle label({
    double size = 11,
    Color color = AppColors.textSub,
    FontWeight weight = FontWeight.w500,
    double spacing = 0.2,
  }) => TextStyle(
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: spacing,
    height: 1.3,
  );
}
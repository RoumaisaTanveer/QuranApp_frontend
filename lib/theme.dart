// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds – slightly more neutral
  static const bg   = Color(0xFF13151A);
  static const bg2  = Color(0xFF181A22);
  static const bg3  = Color(0xFF1E2028);
  static const bg4  = Color(0xFF242732);
  static const card = Color(0xFF181A22);

  // Purple — toned down
  static const purple      = Color(0xFF6A56C9);
  static const purpleLight = Color(0xFF8B74D4);
  static const purpleDim   = Color(0x226A56C9);
  static const purpleGlow  = Color(0x556A56C9);

  // Gold — spiritual accent
  static const gold      = Color(0xFFD4A84B);
  static const goldLight = Color(0xFFEDC870);
  static const goldDim   = Color(0x22D4A84B);
  static const goldGlow  = Color(0x44D4A84B);

  // Green — main primary accent
  static const green      = Color(0xFF1F6B4A);
  static const greenSoft  = Color(0xFF2C815A);
  static const greenDim   = Color(0x221F6B4A);
  static const greenGlow  = Color(0x441F6B4A);

  // Semantic
  static const red    = Color(0xFFE84545);
  static const orange = Color(0xFFE8944A);
  static const blue   = Color(0xFF4A90E2);

  // Text
  static const text      = Color(0xFFEEEFF5);
  static const textSub   = Color(0xFF9595A8);
  static const textDim   = Color(0xFF80809A);
  static const textMuted = Color(0xFF4C4C5A);

  // Borders
  static const border      = Color(0xFF2A2C39);
  static const borderLight = Color(0xFF353749);
  static const borderMid   = Color(0xFF353749);
  static const borderGold  = Color(0x33D4A84B); // gold-tinted border for verse cards
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,      // main accent (buttons, FABs, active states)
      secondary: AppColors.purple,   // secondary accent
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
  }) =>
      TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing ?? (size > 16 ? -0.5 : -0.2),
        height: height ?? 1.45,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      );

  // Arabic — always gold, Amiri font
  static TextStyle arabic({
    double size = 22,
    Color color = AppColors.goldLight,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
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
  }) =>
      TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
        height: 1.3,
      );
}

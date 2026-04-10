import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF164EA0);  // Deep blue
  static const Color primaryL  = Color(0xFFEBF2FF);
  static const Color accent    = Color(0xFF228B22);  // Green
  static const Color accentL   = Color(0xFFEBFFEB);
  static const Color warning   = Color(0xFFE67E22);
  static const Color surface   = Color(0xFFF7F8FC);
  static const Color card      = Color(0xFFFFFFFF);
  static const Color textDark  = Color(0xFF14141E);
  static const Color textMid   = Color(0xFF5A5A64);
  static const Color textLight = Color(0xFF9E9EAB);
  static const Color divider   = Color(0xFFE4E4EE);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: divider, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      labelStyle: const TextStyle(color: textMid, fontFamily: 'Cairo'),
      hintStyle: const TextStyle(color: textLight, fontFamily: 'Cairo'),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: textLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
    ),
    dividerTheme: const DividerThemeData(color: divider, thickness: 1),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textDark),
      titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textDark, fontSize: 20),
      titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textDark, fontSize: 16),
      bodyLarge: TextStyle(fontFamily: 'Cairo', color: textDark, fontSize: 15),
      bodyMedium: TextStyle(fontFamily: 'Cairo', color: textMid, fontSize: 13),
    ),
  );
}

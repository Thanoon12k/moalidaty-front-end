import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static const font = 'Cairo';

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.primary,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: Colors.white,
      secondary: p.accent,
      surface: p.surface,
      onSurface: p.textPrimary,
      error: p.danger,
      outline: p.border,
    );

    final radius = BorderRadius.circular(14);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: font,
      colorScheme: scheme,
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: p.border,
          disabledForegroundColor: p.textMuted,
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontFamily: font,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primary,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontFamily: font, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(fontFamily: font, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(p.primary, 1.6),
        errorBorder: border(p.danger),
        focusedErrorBorder: border(p.danger, 1.6),
        labelStyle: TextStyle(color: p.textSecondary, fontFamily: font),
        floatingLabelStyle: TextStyle(color: p.primary, fontFamily: font),
        hintStyle: TextStyle(color: p.textMuted, fontFamily: font),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.accent,
        side: BorderSide(color: p.border),
        labelStyle: TextStyle(fontFamily: font, color: p.textPrimary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(fontFamily: font, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
        ),
        contentTextStyle: TextStyle(fontFamily: font, fontSize: 14, color: p.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.light ? const Color(0xFF1E2133) : p.surfaceAlt,
        contentTextStyle: const TextStyle(fontFamily: font, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(fontFamily: font, color: p.textPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceAlt,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.primary : p.surfaceAlt,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: p.textPrimary, fontSize: 26, height: 1.2),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary, fontSize: 20),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary, fontSize: 16),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, color: p.textPrimary, fontSize: 14),
        bodyLarge: TextStyle(color: p.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: p.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: p.textMuted, fontSize: 11.5),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, color: p.textPrimary, fontSize: 14),
      ),
    );
  }
}

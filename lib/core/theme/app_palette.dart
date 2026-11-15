import 'package:flutter/material.dart';

/// Design tokens for both themes. Widgets read them with `context.palette`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  // Surfaces
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color shadow;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  // Brand
  final Color primary;
  final Color primarySoft;
  final Color accent;      // cyan — selected toggles & chips
  final Color accentSoft;
  final Color fab;         // green round "+" in the bottom bar

  // Status (good / warning / critical) — always paired with an icon or label
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;

  // Icon tiles
  final Color purple;
  final Color purpleSoft;
  final Color orange;
  final Color orangeSoft;

  // Hero balance card
  final List<Color> heroGradient;

  // Charts — categorical slots (fixed order) and the ordinal blue ramp,
  // validated with the dataviz palette checks for this theme's card surface.
  final List<Color> series;
  final List<Color> ordinal;
  final Color grid;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.shadow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.primarySoft,
    required this.accent,
    required this.accentSoft,
    required this.fab,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.purple,
    required this.purpleSoft,
    required this.orange,
    required this.orangeSoft,
    required this.heroGradient,
    required this.series,
    required this.ordinal,
    required this.grid,
  });

  static const light = AppPalette(
    background: Color(0xFFF3F4FA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF6F7FB),
    border: Color(0xFFE8EAF2),
    shadow: Color(0x141E2A5A),
    textPrimary: Color(0xFF181B2C),
    textSecondary: Color(0xFF656A80),
    textMuted: Color(0xFF9EA3B8),
    primary: Color(0xFF2C4BD6),
    primarySoft: Color(0xFFE8EDFF),
    accent: Color(0xFF16A9DF),
    accentSoft: Color(0xFFE2F6FD),
    fab: Color(0xFF2FC46B),
    success: Color(0xFF14A44D),
    successSoft: Color(0xFFE4F7EC),
    warning: Color(0xFFE59A00),
    warningSoft: Color(0xFFFFF4DB),
    danger: Color(0xFFDC3B3B),
    dangerSoft: Color(0xFFFDE8E8),
    purple: Color(0xFF6A55E0),
    purpleSoft: Color(0xFFEEEBFF),
    orange: Color(0xFFF07F2F),
    orangeSoft: Color(0xFFFFEEE0),
    heroGradient: [Color(0xFF3A86F2), Color(0xFF1F55D6), Color(0xFF13389E)],
    series: [Color(0xFF2A78D6), Color(0xFFEB6834), Color(0xFF1BAF7A), Color(0xFFEDA100)],
    ordinal: [Color(0xFF86B6EF), Color(0xFF3987E5), Color(0xFF256ABF), Color(0xFF184F95)],
    grid: Color(0xFFEDEEF4),
  );

  static const dark = AppPalette(
    background: Color(0xFF0E1018),
    surface: Color(0xFF171A24),
    surfaceAlt: Color(0xFF1E2230),
    border: Color(0xFF282D3C),
    shadow: Color(0x40000000),
    textPrimary: Color(0xFFF1F3F9),
    textSecondary: Color(0xFFA9AEC2),
    textMuted: Color(0xFF6E748A),
    primary: Color(0xFF6E8BFF),
    primarySoft: Color(0xFF232C4D),
    accent: Color(0xFF2BBBEB),
    accentSoft: Color(0xFF143241),
    fab: Color(0xFF2FC46B),
    success: Color(0xFF3CCB72),
    successSoft: Color(0xFF15301F),
    warning: Color(0xFFF5B124),
    warningSoft: Color(0xFF33290F),
    danger: Color(0xFFF06464),
    dangerSoft: Color(0xFF3A1A1C),
    purple: Color(0xFF9A8AF2),
    purpleSoft: Color(0xFF26223F),
    orange: Color(0xFFF59A55),
    orangeSoft: Color(0xFF3A2616),
    heroGradient: [Color(0xFF2F6FE0), Color(0xFF1C47B8), Color(0xFF102C7A)],
    series: [Color(0xFF3987E5), Color(0xFFD95926), Color(0xFF199E70), Color(0xFFC98500)],
    ordinal: [Color(0xFF9EC5F4), Color(0xFF5598E7), Color(0xFF2A78D6), Color(0xFF1C5CAB)],
    grid: Color(0xFF242836),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      t < 0.5 ? this : (other as AppPalette? ?? this);
}

extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

import 'package:flutter/material.dart';

/// Color palettes sourced from Design.md (Light = Sushi Red / Sumie / Rice White,
/// Dark = Zen Precision / Crimson / Ink). Both are Material 3 tonal sets.
class AppColors {
  AppColors._();

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF1C1B1B),
    onPrimaryContainer: Color(0xFF858383),
    inversePrimary: Color(0xFFC8C6C5),
    secondary: Color(0xFFB7102A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDB313F),
    onSecondaryContainer: Color(0xFFFFFBFF),
    tertiary: Color(0xFF000000),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF1A1C1C),
    onTertiaryContainer: Color(0xFF838484),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF9F9F9),
    onSurface: Color(0xFF1A1C1C),
    onSurfaceVariant: Color(0xFF444748),
    outline: Color(0xFF747878),
    outlineVariant: Color(0xFFC4C7C7),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F3F3),
    surfaceContainer: Color(0xFFEEEEEE),
    surfaceContainerHigh: Color(0xFFE8E8E8),
    surfaceContainerHighest: Color(0xFFE2E2E2),
    inverseSurface: Color(0xFF2F3131),
    onInverseSurface: Color(0xFFF1F1F1),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF5F5E5E),
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB3B1),
    onPrimary: Color(0xFF680011),
    primaryContainer: Color(0xFFFF535B),
    onPrimaryContainer: Color(0xFF5B000E),
    inversePrimary: Color(0xFFBB152C),
    secondary: Color(0xFFC8C6C5),
    onSecondary: Color(0xFF313030),
    secondaryContainer: Color(0xFF474746),
    onSecondaryContainer: Color(0xFFB7B5B4),
    tertiary: Color(0xFFC6C6C7),
    onTertiary: Color(0xFF2F3131),
    tertiaryContainer: Color(0xFF909191),
    onTertiaryContainer: Color(0xFF282A2A),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF131313),
    onSurface: Color(0xFFE4E2E1),
    onSurfaceVariant: Color(0xFFE4BEBC),
    outline: Color(0xFFAB8987),
    outlineVariant: Color(0xFF5B403F),
    surfaceContainerLowest: Color(0xFF0E0E0E),
    surfaceContainerLow: Color(0xFF1B1C1C),
    surfaceContainer: Color(0xFF1F2020),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF353535),
    inverseSurface: Color(0xFFE4E2E1),
    onInverseSurface: Color(0xFF303030),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFFFFB3B1),
  );

  /// Functional accents used by status chips and indicators.
  static const Color success = Color(0xFFA8DADC);
  static const Color warning = Color(0xFFFFB74D);
  static const Color matcha = Color(0xFFA8DADC);
}

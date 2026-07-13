import 'package:flutter/material.dart';

/// Color palettes sourced from Design.md (Light = Sushi Red / Sumie / Rice White,
/// Dark = Zen Precision / Crimson / Ink). Both are Material 3 tonal sets.
class AppColors {
  AppColors._();

  static const Color sumieBlack = Color(0xFF1A1C1C);
  static const Color sushiRed = Color(0xFFE63946);
  static const Color sushiRedDark = Color(0xFFB7102A);
  static const Color riceWhite = Color(0xFFFDFDFD);
  static const Color inkGray = Color(0xFF757575);
  static const Color matcha = Color(0xFFA8DADC);

  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: sumieBlack,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF303232),
    onPrimaryContainer: Color(0xFFE8E8E8),
    inversePrimary: Color(0xFFC8C6C5),
    secondary: sushiRed,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFDAD8),
    onSecondaryContainer: Color(0xFF5B000E),
    tertiary: sumieBlack,
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFE2E2E2),
    onTertiaryContainer: sumieBlack,
    error: sushiRedDark,
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: riceWhite,
    onSurface: sumieBlack,
    onSurfaceVariant: Color(0xFF444748),
    outline: inkGray,
    outlineVariant: Color(0xFFE1E4E4),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F7F7),
    surfaceContainer: Color(0xFFF1F1F1),
    surfaceContainerHigh: Color(0xFFEDEDED),
    surfaceContainerHighest: Color(0xFFE2E2E2),
    inverseSurface: Color(0xFF2F3131),
    onInverseSurface: Color(0xFFF1F1F1),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: sushiRed,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFB3B1),
    onPrimary: Color(0xFF680011),
    primaryContainer: Color(0xFFFF535B),
    onPrimaryContainer: Color(0xFF5B000E),
    inversePrimary: Color(0xFFBB152C),
    secondary: Color(0xFFFF535B),
    onSecondary: Color(0xFF410007),
    secondaryContainer: Color(0xFF92001C),
    onSecondaryContainer: Color(0xFFFFDAD8),
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
  static const Color success = matcha;
  static const Color warning = Color(0xFFFFB74D);
}

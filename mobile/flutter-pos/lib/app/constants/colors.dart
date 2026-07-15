import 'package:flutter/material.dart';

/// "Minimalis Putih" premium palette — salmon-only accent system.
///
/// Design tokens (single source of truth — do not hardcode hex elsewhere):
///  - ink        #111315  primary text / high-contrast elements
///  - inkMuted   #8A8F98  secondary text, icons, placeholders
///  - inkFaint   #B9BCC2  disabled / tertiary text
///  - surface    #FFFFFF  page background
///  - surfaceAlt #FAFAFA  subtle secondary surface (strips, headers)
///  - salmon     #FA8072  PRIMARY accent — used for CTAs, badges, active
///                        states, AND card/container tints (single accent
///                        family, varied by tone/opacity, not by hue)
///  - salmonDark #D8695C  pressed/hover state, high-contrast salmon text
///  - salmonSoft #FFEDE8  salmon tint used as card/container background
///  - salmonBorder #FAD3CB  salmon-tinted 1px borders
///  - hairline   #ECECEE  neutral 1px borders replacing heavy shadows
class AppColors {
  AppColors._();

  static const Color ink = Color(0xFF111315);
  static const Color inkMuted = Color(0xFF8A8F98);
  static const Color inkFaint = Color(0xFFB9BCC2);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFAFAFA);
  static const Color hairline = Color(0xFFECECEE);

  /// Primary (and only) accent — Salmon. Used for CTAs (Bayar/Pay),
  /// active states, selected chips, badges, and card/container tints.
  static const Color salmon = Color(0xFFFA8072);
  static const Color salmonDark =
      Color(0xFFD8695C); // pressed state, on-light text
  static const Color salmonSoft = Color(0xFFFFEDE8); // container / tint bg
  static const Color salmonBorder = Color(0xFFFAD3CB); // tinted hairline

  // Neutral semantic colors (kept minimal, low-chroma, not "bright")
  static const Color danger = Color(0xFFE23744);
  static const Color dangerSoft = Color(0xFFFCE9EA);
  static const Color warning = Color(0xFFB9812A);

  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: salmon,
    onPrimary: Colors.white,
    primaryContainer: salmonSoft,
    onPrimaryContainer: salmonDark,
    inversePrimary: salmonSoft,
    secondary: salmonDark,
    onSecondary: Colors.white,
    secondaryContainer: salmonSoft,
    onSecondaryContainer: ink,
    tertiary: ink,
    onTertiary: Colors.white,
    tertiaryContainer: surfaceAlt,
    onTertiaryContainer: ink,
    error: danger,
    onError: Colors.white,
    errorContainer: dangerSoft,
    onErrorContainer: danger,
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: inkMuted,
    outline: hairline,
    outlineVariant: salmonBorder,
    surfaceContainerLowest: surface,
    surfaceContainerLow: surfaceAlt,
    surfaceContainer: surfaceAlt,
    surfaceContainerHigh: salmonSoft,
    surfaceContainerHighest: Color(0xFFF3F3F4),
    inverseSurface: ink,
    onInverseSurface: surface,
    shadow: Color(0x14111315),
    scrim: Color(0x66111315),
    surfaceTint: salmon,
  );
}

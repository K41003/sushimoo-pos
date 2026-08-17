import 'dart:ui';
import 'package:flutter/material.dart';

/// "Glassmorphic Zen" design tokens — SUSHIMOO POS Pro Max.
///
/// This REPLACES the old "Modern Minimalis" flat-card token file 1:1 —
/// every constant that existed before (`AppColors.salmon`, `AppColors.ink`,
/// `AppColors.shadowSm`, `AppColors.scheme`, etc.) still exists with the
/// same name and type, so every screen that hasn't been redesigned yet
/// keeps compiling and looking correct. New glass-specific tokens are
/// additive (canvas gradient, glass fill/border, blur sigma).
///
/// Layering model for any redesigned screen:
///   1. [canvasGradient]                     full-screen gradient backdrop
///   2. [glassFill] + [glassBorder] + blur    the "glass" panel itself
///   3. [salmon] / [salmonDark]               accent CTAs, active states
///
/// Single source of truth — do not hardcode hex/alpha elsewhere.
class AppColors {
  AppColors._();

  // ---- Legacy flat-surface tokens (kept for un-migrated screens) --------
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFE2E8F0);

  // ---- Background gradient canvas (glass screens) ------------------------
  static const Color bgGradientStart = Color(0xFFFFF3EE); // warm salmon-tinted
  static const Color bgGradientEnd = Color(0xFFEFF3FB); // cool slate-tinted
  static const Color bgBase = Color(0xFFF3F5FA);

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgGradientStart, bgBase, bgGradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  /// Large soft color blobs painted behind glass panels to give the
  /// "frosted glass over colored light" effect. Keep opacity low.
  static const Color blobSalmon = Color(0x33FF7A59);
  static const Color blobBlue = Color(0x332F6FED);
  static const Color blobMint = Color(0x3310B981);

  // ---- Glass surface ------------------------------------------------------
  /// Fill color for a glass panel — white at low opacity so the gradient
  /// and blobs behind it bleed through after the blur filter is applied.
  static Color glassFill({double opacity = 0.55}) =>
      Colors.white.withValues(alpha: opacity);

  /// A slightly stronger fill for panels that need better text contrast
  /// (forms, price summaries) without losing the glass feel.
  static Color glassFillStrong({double opacity = 0.72}) =>
      Colors.white.withValues(alpha: opacity);

  /// Hairline border that catches the "light" on the glass edge.
  static Color glassBorder({double opacity = 0.6}) =>
      Colors.white.withValues(alpha: opacity);

  static Color glassBorderSubtle({double opacity = 0.35}) =>
      Colors.white.withValues(alpha: opacity);

  /// Standard blur sigma for BackdropFilter. 14–18 reads as "frosted",
  /// staying under 20 keeps text behind panels legible for a11y.
  static const double blurSigma = 16.0;
  static const double blurSigmaLight = 10.0;

  // ---- Text (kept high-contrast on purpose — glass needs strong ink) ----
  static const Color ink = Color(0xFF10182B); // near-black navy, not pure black
  static const Color inkMuted = Color(0xFF4B5568);
  static const Color inkFaint = Color(0xFF8B94A8);

  // ---- Accent: Orange Salmon (unchanged brand identity) -----------------
  static const Color salmon = Color(0xFFFF7A59);
  static const Color salmonDark = Color(0xFFF2643D);
  static const Color salmonSoft = Color(0xFFFFEDE6);
  static const Color salmonBorder = Color(0xFFFFC9B3);

  static const LinearGradient salmonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8A65), salmon, salmonDark],
  );

  // ---- Semantic colors -----------------------------------------------------
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);

  /// Success / positive semantic color (confirmations, change due).
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldSoft = Color(0xFFE1F9F0);

  /// Tailwind-style neutral "slate" scale used for low-emphasis surfaces.
  static const MaterialColor slate = MaterialColor(
    0xFF64748B,
    <int, Color>{
      50: Color(0xFFF8FAFC),
      100: Color(0xFFF1F5F9),
      200: Color(0xFFE2E8F0),
      300: Color(0xFFCBD5E1),
      400: Color(0xFF94A3B8),
      500: Color(0xFF64748B),
      600: Color(0xFF475569),
      700: Color(0xFF334155),
      800: Color(0xFF1E293B),
      900: Color(0xFF0F172A),
    },
  );

  // ---- Soft shadows --------------------------------------------------------
  // Legacy flat-card shadow API (still used by un-migrated screens).
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
            color: ink.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3)),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(
            color: ink.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8)),
      ];
  static List<BoxShadow> get shadowLg => [
        BoxShadow(
            color: ink.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 16)),
      ];

  /// Warm salmon-tinted glow used behind primary CTAs on glass screens.
  static List<BoxShadow> get shadowSalmon => [
        BoxShadow(
            color: salmon.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8)),
      ];

  static ColorScheme get scheme => ColorScheme(
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
        tertiaryContainer: bgBase,
        onTertiaryContainer: ink,
        error: danger,
        onError: Colors.white,
        errorContainer: dangerSoft,
        onErrorContainer: danger,
        surface: bgBase,
        onSurface: ink,
        onSurfaceVariant: inkMuted,
        outline: const Color(0xFFE2E8F0),
        outlineVariant: const Color(0xFFEDF1F7),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: bgBase,
        surfaceContainer: const Color(0xFFF1F5F9),
        surfaceContainerHigh: const Color(0xFFF1F5F9),
        surfaceContainerHighest: const Color(0xFFE9EDF5),
        inverseSurface: ink,
        onInverseSurface: Colors.white,
        shadow: const Color(0x1A10182B),
        scrim: const Color(0x66111315),
        surfaceTint: salmon,
      );
}

/// Reusable blur filter shorthand so every glass widget applies the exact
/// same sigma (consistency = the whole point of a design system).
ImageFilter glassBlurFilter({double sigma = AppColors.blurSigma}) =>
    ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);

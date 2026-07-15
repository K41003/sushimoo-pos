import 'package:flutter/material.dart';

/// "Modern Minimalis / Clean UI" design tokens — floating white cards on a
/// calm slate background, with a single warm Orange-Salmon accent.
///
/// Single source of truth — do not hardcode hex elsewhere.
///
///  - background  #F8FAFC  calm slate-50 page canvas
///  - card        #FFFFFF  white surface that floats via soft shadow
///  - ink         #0F172A  charcoal primary text (Slate 900)
///  - inkMuted    #475569  secondary text (Slate 600)
///  - inkFaint    #94A3B8  tertiary / disabled text (Slate 400)
///  - salmon      #FF7A59  ORANGE-SALMON accent (CTAs, active, badges)
///  - hairline    #E2E8F0  soft 1px borders (Slate 200)
class AppColors {
  AppColors._();

  // ---- Backgrounds & surfaces -------------------------------------------
  static const Color background = Color(0xFFF8FAFC); // page canvas (slate-50)
  static const Color surface = Color(0xFFF8FAFC); // alias of background
  static const Color card = Color(0xFFFFFFFF); // floating card surface
  static const Color surfaceAlt = Color(0xFFFFFFFF); // white inputs / active
  static const Color hairline = Color(0xFFE2E8F0); // slate-200

  // ---- Text (Slate / Charcoal) ------------------------------------------
  static const Color ink = Color(0xFF0F172A); // slate-900
  static const Color inkMuted = Color(0xFF475569); // slate-600
  static const Color inkFaint = Color(0xFF94A3B8); // slate-400

  // ---- Accent: Orange Salmon --------------------------------------------
  static const Color salmon = Color(0xFFFF7A59);
  static const Color salmonDark = Color(0xFFF2643D); // pressed / hover
  static const Color salmonSoft = Color(0xFFFFF0EB); // tinted container bg
  static const Color salmonBorder = Color(0xFFFFD6C9); // tinted hairline

  // ---- Semantic colors (kept minimal, low-chroma) -----------------------
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);

  /// Success / positive semantic color (confirmations, change due).
  static const Color emerald = Color(0xFF10B981);

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

  // ---- Soft shadows (high blur, low opacity → elegant float) ------------
  static List<BoxShadow> get shadowSm => const [
        BoxShadow(color: Color(0x0D1E293B), blurRadius: 10, offset: Offset(0, 2)),
      ];
  static List<BoxShadow> get shadowMd => const [
        BoxShadow(color: Color(0x121A2433), blurRadius: 18, offset: Offset(0, 6)),
      ];
  static List<BoxShadow> get shadowLg => const [
        BoxShadow(color: Color(0x1A0F172A), blurRadius: 30, offset: Offset(0, 12)),
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
        tertiaryContainer: background,
        onTertiaryContainer: ink,
        error: danger,
        onError: Colors.white,
        errorContainer: dangerSoft,
        onErrorContainer: danger,
        surface: background,
        onSurface: ink,
        onSurfaceVariant: inkMuted,
        outline: hairline,
        outlineVariant: const Color(0xFFE2E8F0),
        surfaceContainerLowest: card,
        surfaceContainerLow: background,
        surfaceContainer: const Color(0xFFF1F5F9),
        surfaceContainerHigh: const Color(0xFFF1F5F9),
        surfaceContainerHighest: const Color(0xFFF1F5F9),
        inverseSurface: ink,
        onInverseSurface: Colors.white,
        shadow: const Color(0x1A0F172A),
        scrim: const Color(0x66111315),
        surfaceTint: salmon,
      );
}

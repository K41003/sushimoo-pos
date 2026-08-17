import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

/// Reusable, on-brand container decorations for "Glassmorphic Zen".
///
/// REPLACES the old flat-card decorations file 1:1 — `AppDecorations.card`,
/// `.tinted`, and `.control` keep the same names/signatures so every
/// un-migrated screen still compiles. They now return translucent glass
/// fills instead of opaque white. NOTE: a [BoxDecoration] alone cannot
/// blur what's behind it — for the true frosted effect wrap content in
/// `GlassPanel` (in `shared/widgets/glass_panel.dart`), which pairs
/// `BackdropFilter` with these same color tokens. These decorations are
/// the fallback for spots that don't warrant a full glass panel (e.g.
/// small inline containers).
class AppDecorations {
  AppDecorations._();

  /// Translucent card: soft radius, hairline glass border, warm shadow.
  /// For the full frosted-blur look, prefer `GlassPanel` instead.
  static BoxDecoration card({
    Color? color,
    double? radius,
    bool border = true,
    List<BoxShadow>? shadow,
    BorderRadius? borderRadius,
  }) =>
      BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.6),
        borderRadius: borderRadius ?? BorderRadius.circular(radius ?? AppDimensions.radiusLg),
        border: border
            ? Border.all(color: AppColors.glassBorder(opacity: 0.7), width: AppDimensions.glassBorderWidth)
            : null,
        boxShadow: shadow ?? AppColors.shadowSm,
      );

  /// Tinted (accent) card — for highlighted or "current" surfaces.
  static BoxDecoration tinted({
    double? radius,
    List<BoxShadow>? shadow,
  }) =>
      BoxDecoration(
        color: AppColors.salmonSoft.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(radius ?? AppDimensions.radiusLg),
        border: Border.all(color: AppColors.salmonBorder, width: 1.2),
        boxShadow: shadow ?? AppColors.shadowSm,
      );

  /// Compact control (stepper, small button) — softer, smaller radius.
  static BoxDecoration control({Color? color, double? radius}) => BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(radius ?? AppDimensions.radiusSm),
        border: Border.all(color: AppColors.glassBorder(opacity: 0.7), width: 1.2),
        boxShadow: AppColors.shadowSm,
      );

  /// Full-bleed page background gradient — apply once per Scaffold body.
  static BoxDecoration get canvas => const BoxDecoration(gradient: AppColors.canvasGradient);
}

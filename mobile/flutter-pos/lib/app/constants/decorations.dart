import 'package:flutter/material.dart';
import 'colors.dart';
import 'dimensions.dart';

/// Reusable, on-brand container decorations for the "Modern Minimalis" look.
///
/// Every card / panel should use [AppDecorations.card] so the app stays
/// consistent: white surface, soft rounded corners (>= 12), a whisper-thin
/// hairline, and a high-blur / low-opacity shadow that makes it float on the
/// #F8FAFC canvas.
class AppDecorations {
  AppDecorations._();

  /// Floating card: white (or [color]) surface, soft radius, hairline, shadow.
  static BoxDecoration card({
    Color? color,
    double? radius,
    bool border = true,
    List<BoxShadow>? shadow,
    BorderRadius? borderRadius,
  }) =>
      BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: borderRadius ?? BorderRadius.circular(radius ?? AppDimensions.radiusLg),
        border: border ? Border.all(color: AppColors.hairline, width: 1) : null,
        boxShadow: shadow ?? AppColors.shadowSm,
      );

  /// Tinted (accent) card — for highlighted or "current" surfaces.
  static BoxDecoration tinted({
    double? radius,
    List<BoxShadow>? shadow,
  }) =>
      BoxDecoration(
        color: AppColors.salmonSoft,
        borderRadius: BorderRadius.circular(radius ?? AppDimensions.radiusLg),
        border: Border.all(color: AppColors.salmonBorder, width: 1),
        boxShadow: shadow ?? AppColors.shadowSm,
      );

  /// Compact control (stepper, small button) — softer, smaller radius.
  static BoxDecoration control({Color? color, double? radius}) => BoxDecoration(
        color: color ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius ?? AppDimensions.radiusSm),
        border: Border.all(color: AppColors.hairline, width: 1),
        boxShadow: AppColors.shadowSm,
      );
}

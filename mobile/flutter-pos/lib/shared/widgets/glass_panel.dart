import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';

/// The single reusable "glass" surface for the whole app.
///
/// NEW FILE — there is no equivalent in the old flat-card system, because
/// `BoxDecoration` alone cannot blur what's behind it. Wraps a
/// [BackdropFilter] + translucent [Container] so every card, sheet, dialog
/// and app bar gets an identical frosted-glass treatment. Always clips to
/// a rounded rect BEFORE blurring, otherwise the blur bleeds past the
/// intended corners.
///
/// Usage:
/// ```dart
/// GlassPanel(
///   padding: const EdgeInsets.all(20),
///   child: Text('Hello glass'),
/// )
/// ```
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double opacity;
  final double blurSigma;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadow;
  final Color? borderColor;
  final Gradient? overlayGradient;
  final bool strong;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppDimensions.radiusLg,
    this.opacity = 0.55,
    this.blurSigma = AppColors.blurSigma,
    this.onTap,
    this.shadow,
    this.borderColor,
    this.overlayGradient,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final fill = strong
        ? AppColors.glassFillStrong(opacity: opacity)
        : AppColors.glassFill(opacity: opacity);

    Widget panel = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadius,
            gradient: overlayGradient,
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder(),
              width: AppDimensions.glassBorderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );

    // Shadow must live OUTSIDE the ClipRRect (clipping would cut it off).
    panel = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow ?? AppColors.shadowMd,
      ),
      child: panel,
    );

    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: panel,
      ),
    );
  }
}

/// Full-screen gradient backdrop with soft floating color blobs, meant to
/// sit behind every [GlassPanel] so the frosted effect has something
/// colorful to blur. Place once per page as the outermost body layer.
class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const GlassBackground({super.key, required this.child, this.showBlobs = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
      child: Stack(
        children: [
          if (showBlobs) ...[
            Positioned(top: -80, right: -60, child: _blob(320, AppColors.blobSalmon)),
            Positioned(top: 260, left: -100, child: _blob(280, AppColors.blobBlue)),
            Positioned(bottom: -100, right: -40, child: _blob(300, AppColors.blobMint)),
          ],
          child,
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

/// Small icon-only glass button — used in app bars / sidebars / card
/// corners. NEW helper widget, no old equivalent.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusSm,
      opacity: 0.55,
      blurSigma: AppColors.blurSigmaLight,
      padding: EdgeInsets.zero,
      shadow: AppColors.shadowSm,
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size * 0.42, color: color ?? AppColors.ink),
      ),
    );
  }
}

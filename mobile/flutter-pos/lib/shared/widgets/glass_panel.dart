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

/// Full-screen backdrop for every page: the app's background gradient,
/// soft floating color blobs, AND a very low-opacity sushi line-art motif
/// (maki roll, nigiri, chopsticks, nori, sesame — see
/// `assets/images/app_background.png`), meant to sit behind every
/// [GlassPanel] so the frosted effect has something to blur. Place once
/// per page as the outermost body layer.
///
/// The artwork is intentionally subtle — it reads clearly in the gaps
/// between glass panels (see any page's margins) but disappears into a
/// soft blur wherever a [GlassPanel] sits on top of it, so it never
/// competes with foreground text or cards.
class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const GlassBackground({super.key, required this.child, this.showBlobs = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.canvasGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showBlobs)
            Image.asset(
              'assets/images/app_background.png',
              fit: BoxFit.cover,
              // The gradient/blob artwork is baked into the PNG itself,
              // so if the asset is ever missing this silently falls back
              // to the plain canvasGradient above instead of crashing.
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          child,
        ],
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import 'glass_panel.dart';

/// REPLACES the old flat `AppCard` 1:1 (same constructor: `child`,
/// `padding`, `onTap`, `tinted`, `borderColor`, `shadow`), so every
/// existing call site across the app keeps compiling. Internally now
/// renders a real frosted-glass surface via [GlassPanel] instead of a
/// flat opaque [Container].
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool tinted;
  final Color? borderColor;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.tinted = false,
    this.borderColor,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusLg.r,
      padding: padding ?? EdgeInsets.all(AppDimensions.cardPadding.r),
      opacity: tinted ? 0.45 : 0.55,
      overlayGradient: tinted
          ? LinearGradient(
              colors: [
                AppColors.salmonSoft.withValues(alpha: 0.9),
                AppColors.salmonSoft.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderColor: borderColor ?? (tinted ? AppColors.salmonBorder : null),
      shadow: shadow,
      onTap: onTap,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/decorations.dart';
import '../../app/constants/dimensions.dart';

/// Base card: white surface that floats on the #F8FAFC canvas via a soft
/// shadow, with a whisper hairline and soft radius.
/// Set [tinted] to use the salmon-soft secondary surface instead (for
/// highlighted / "current" items, e.g. the active cart summary panel).
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
    final radius = BorderRadius.circular(AppDimensions.radiusLg.r);
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppDimensions.cardPadding.r),
      decoration: tinted
          ? AppDecorations.tinted(radius: AppDimensions.radiusLg, shadow: shadow)
          : BoxDecoration(
              color: AppColors.card,
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? AppColors.hairline,
                width: 1,
              ),
              boxShadow: shadow ?? AppColors.shadowSm,
            ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: card,
    );
  }
}


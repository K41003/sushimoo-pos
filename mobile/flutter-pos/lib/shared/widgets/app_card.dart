import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';

/// Base card: white surface, 1px hairline border, soft radius — no shadow.
/// Set [tinted] to use the salmon-soft secondary surface instead (for
/// highlighted / "current" items, e.g. the active cart summary panel).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool tinted;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.tinted = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLg.r);
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppDimensions.cardPadding.r),
      decoration: BoxDecoration(
        color: tinted ? AppColors.salmonSoft : AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? (tinted ? AppColors.salmonBorder : AppColors.hairline),
          width: 1,
        ),
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

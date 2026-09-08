import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../shared/widgets/glass_panel.dart';

/// REPLACES `stat_card.dart` 1:1 — same class name `StatCard`, same
/// constructor (`label`, `value`, `icon`). Optional `trend`/`accent`
/// kept as new opt-in params with safe defaults so old call sites
/// (`StatCard(label: ..., value: ..., icon: ...)`) still compile.
///
/// UI FIX: when `trend` was null, the card used to still render a faint
/// static `Icons.trending_up` glyph in the top-right corner — a decoration
/// that looks like it means something ("this is trending up") but
/// actually carries no data. That's misleading at a glance. The card now
/// renders nothing in that slot when there's no real trend to show,
/// instead of a placeholder icon that could be misread as a signal.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? trend;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = AppColors.salmon,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.md.w,
        vertical: AppDimensions.xs.h + 2.h,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tight = constraints.maxHeight < 85;
          final gapTop = tight ? 2.h : 6.h;
          final gapLabel = tight ? 1.h : 3.h;

          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, color: accent, size: 18.sp),
                      ),
                      const Spacer(),
                      if (trend != null)
                        Row(
                          children: [
                            Icon(Icons.trending_up, size: 13.sp, color: AppColors.emerald),
                            SizedBox(width: 2.w),
                            Text(
                              trend!,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.emerald,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: gapTop),
                  Text(
                    value,
                    style: AppTypography.priceCompact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: gapLabel),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

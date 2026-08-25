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
      padding: EdgeInsets.all(AppDimensions.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accent, size: 20.sp),
              ),
              const Spacer(),
              if (trend != null)
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 14.sp, color: AppColors.emerald),
                    SizedBox(width: 2.w),
                    Text(
                      trend!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: AppDimensions.sm.h + 2.h),
          Text(value, style: AppTypography.price),
          SizedBox(height: 4.h),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

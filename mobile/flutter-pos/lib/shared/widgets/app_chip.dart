import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/strings.dart';

/// REPLACES the old flat `AppChip` 1:1 (same constructor: `label`,
/// `color`, `onTap`, `selected`). Selected state now fills with the
/// salmon gradient + glow; unselected stays a quiet frosted pill.
///
/// BUG FIX: category chips could appear stuck on the first-selected
/// category and not visually update when tapping a different one, even
/// though the underlying `selectedCategoryId` value did change. Root
/// cause: chips were built without a `Key` inside a `ListView.builder`/
/// `ListView.separated`. Without a stable key, Flutter's element
/// reconciliation can match a chip's `AnimatedContainer` state to the
/// wrong list position when items shift or a rebuild only marks *some*
/// widgets dirty — the `selected` flag passed in was correct, but a
/// stale `AnimatedContainer` render object could keep showing its old
/// interpolated decoration instead of restarting the animation to the
/// new value. Giving each chip a `ValueKey` tied to its label makes
/// Flutter track the correct widget identity across rebuilds, so the
/// `selected` gradient always follows the tapped chip immediately.
class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool selected;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key ?? ValueKey('chip_$label'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        key: ValueKey('chip_container_${label}_$selected'),
        duration: const Duration(milliseconds: 140),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [color ?? AppColors.salmon, (color ?? AppColors.salmonDark)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.glassBorder(opacity: 0.7),
            width: 1.2,
          ),
          boxShadow: selected ? AppColors.shadowSalmon : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: selected ? Colors.white : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Status pill for order / table states — REPLACES the old `StatusChip`
/// 1:1 (same constructor: `status`). Quiet frosted tint + dot.
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  Color _dot(String s) {
    switch (s) {
      case 'paid':
      case 'available':
        return AppColors.salmonDark;
      case 'pending':
      case 'occupied':
      case 'open':
        return AppColors.warning;
      case 'cancelled':
      case 'closed':
        return AppColors.danger;
      default:
        return AppColors.inkMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = _dot(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          SizedBox(width: 7.w),
          Text(
            statusLabel(status),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

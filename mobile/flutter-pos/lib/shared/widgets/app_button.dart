import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';

/// Standard button.
///
/// `primary: true` -> solid emerald CTA (reserved for the one loud action
/// per screen, e.g. "Bayar" / "Place Order").
/// `primary: false` -> quiet ink-outline secondary action.
/// `fullWidth: false` -> shrinks to content, safe inside a Row without
/// Expanded (theme's minimumSize width is otherwise double.infinity).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final IconData? icon;
  final double? height;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.loading = false,
    this.icon,
    this.height,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final spinnerColor = primary ? Colors.white : AppColors.ink;
    final child = loading
        ? SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: spinnerColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.sp),
                SizedBox(width: 8.w),
              ],
              Text(label),
            ],
          );

    final ButtonStyle? sizeOverride = fullWidth
        ? null
        : ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              Size(0, (height ?? AppDimensions.buttonHeight).h),
            ),
          );

    final box = SizedBox(
      height: (height ?? AppDimensions.buttonHeight).h,
      child: primary
          ? ElevatedButton(style: sizeOverride, onPressed: loading ? null : onPressed, child: child)
          : OutlinedButton(style: sizeOverride, onPressed: loading ? null : onPressed, child: child),
    );
    return box;
  }
}

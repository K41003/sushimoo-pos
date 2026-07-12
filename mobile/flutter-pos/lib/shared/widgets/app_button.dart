import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/dimensions.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final IconData? icon;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.primary = true,
    this.loading = false,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, size: 20.sp),
              if (icon != null) SizedBox(width: 8.w),
              Text(label),
            ],
          );

    if (primary) {
      return SizedBox(
        height: (height ?? AppDimensions.buttonHeight).h,
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      );
    }
    return SizedBox(
      height: (height ?? AppDimensions.buttonHeight).h,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: child,
      ),
    );
  }
}

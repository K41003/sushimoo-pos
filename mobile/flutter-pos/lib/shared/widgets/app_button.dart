import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';

/// Standard button — REPLACES the old flat `AppButton` 1:1 (same
/// constructor: `label`, `onPressed`, `primary`, `loading`, `icon`,
/// `height`, `fullWidth`), so every existing call site keeps compiling.
///
/// `primary: true` -> gradient salmon CTA with a soft glow shadow and a
/// press scale-down micro-interaction (reserved for the one loud action
/// per screen, e.g. "Bayar" / "Place Order").
/// `primary: false` -> quiet frosted-glass secondary action.
/// `fullWidth: false` -> shrinks to content, safe inside a Row without
/// Expanded.
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final h = (widget.height ?? AppDimensions.buttonHeight).h;
    final spinnerColor = widget.primary ? Colors.white : AppColors.ink;

    final child = widget.loading
        ? SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: spinnerColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20.sp, color: widget.primary ? Colors.white : AppColors.ink),
                SizedBox(width: 8.w),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5.sp,
                  color: widget.primary ? Colors.white : AppColors.ink,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: h,
          width: widget.fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: widget.fullWidth ? 0 : 24.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.primary
                ? (_enabled
                    ? AppColors.salmonGradient
                    : LinearGradient(colors: [
                        AppColors.salmon.withValues(alpha: 0.35),
                        AppColors.salmonDark.withValues(alpha: 0.35),
                      ]))
                : null,
            color: widget.primary ? null : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            border: widget.primary
                ? null
                : Border.all(color: AppColors.glassBorder(), width: 1.2),
            boxShadow: widget.primary && _enabled && !_pressed ? AppColors.shadowSalmon : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import 'app_button.dart';
import 'glass_panel.dart';

/// REPLACES `app_dialog.dart` 1:1 — same class name `AppDialog`, same
/// static method signatures (`confirm`, `info`), so every existing call
/// site (delete confirmations across Table/Stock/Ingredient/Category/
/// Product controllers, shift close, closing report, expense delete)
/// keeps compiling with zero changes.
///
/// UI CHANGE: this used to build a stock `AlertDialog` — a flat white
/// rounded rect with default Material text buttons, visually out of
/// place next to every other surface in the app (which are all glass
/// panels with the salmon accent). It's now a [GlassPanel] with an
/// [AppButton] pair, matching the same frosted/blur + gradient CTA
/// language used everywhere else (forms, POS cart, table picker, etc).
///
/// `confirm()` also now supports an optional `destructive` flag: when
/// true (the common case — delete actions), the confirm button renders
/// in the danger red instead of the brand salmon gradient, so a
/// destructive action visually reads as different from a normal
/// primary action. Existing call sites don't pass it, so they keep the
/// old salmon-primary look unless updated to opt into the red variant.
class AppDialog {
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    bool destructive = false,
  }) {
    return Get.dialog<bool>(
      _GlassConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        destructive: destructive,
      ),
    );
  }

  static Future<void> info(String title, String message) {
    return Get.dialog(
      _GlassInfoDialog(title: title, message: message),
    );
  }

  static Future<T?> form<T>({
    required String title,
    required Widget content,
    String confirmText = 'Simpan',
    String cancelText = 'Batal',
    IconData? icon,
    double? maxWidth,
    Future<bool> Function()? onConfirm,
    List<Widget>? customActions,
  }) {
    return Get.dialog<T>(
      _GlassFormDialog<T>(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        maxWidth: maxWidth,
        onConfirm: onConfirm,
        customActions: customActions,
      ),
    );
  }
}

class _GlassConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool destructive;

  const _GlassConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.destructive,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.w),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (destructive ? AppColors.danger : AppColors.salmon).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  destructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded,
                  color: destructive ? AppColors.danger : AppColors.salmon,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: AppDimensions.md.h),
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8.h),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: AppDimensions.lg.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: cancelText,
                      primary: false,
                      onPressed: () => Get.back(result: false),
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm.w),
                  Expanded(
                    child: _ConfirmButton(
                      label: confirmText,
                      destructive: destructive,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thin wrapper around [AppButton] that swaps the salmon gradient for a
/// flat danger-red fill when `destructive` is true. `AppButton` itself
/// only supports the brand gradient for `primary: true`, so this keeps
/// that component untouched and does the red-fill variant locally,
/// scoped to this one dialog's confirm action.
class _ConfirmButton extends StatelessWidget {
  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.label,
    required this.destructive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!destructive) {
      return AppButton(label: label, onPressed: onPressed);
    }
    return SizedBox(
      height: AppDimensions.buttonHeight.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5.sp),
        ),
      ),
    );
  }
}

class _GlassInfoDialog extends StatelessWidget {
  final String title;
  final String message;

  const _GlassInfoDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.w),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8.h),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: AppDimensions.lg.h),
              AppButton(label: 'OK', onPressed: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassFormDialog<T> extends StatefulWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final double? maxWidth;
  final Future<bool> Function()? onConfirm;
  final List<Widget>? customActions;

  const _GlassFormDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    this.icon,
    this.maxWidth,
    this.onConfirm,
    this.customActions,
  });

  @override
  State<_GlassFormDialog<T>> createState() => _GlassFormDialogState<T>();
}

class _GlassFormDialogState<T> extends State<_GlassFormDialog<T>> {
  bool _loading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm == null) {
      Get.back(result: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final success = await widget.onConfirm!();
      if (success && mounted) {
        Get.back(result: true);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 24.h,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 460.w),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      width: 38.r,
                      height: 38.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.salmonGradient,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: AppColors.shadowSm,
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColors.inkMuted),
                    onPressed: () => Get.back(result: false),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: widget.content,
                ),
              ),
              SizedBox(height: 20.h),
              if (widget.customActions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: widget.customActions!,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: widget.cancelText,
                        primary: false,
                        onPressed: () => Get.back(result: false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: widget.confirmText,
                        loading: _loading,
                        onPressed: _handleConfirm,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

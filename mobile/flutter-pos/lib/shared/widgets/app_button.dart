import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/dimensions.dart';

/// Tombol standar aplikasi.
///
/// FIX: menambahkan [fullWidth]. Style default ElevatedButton di
/// `theme.dart` memakai `minimumSize: Size(double.infinity, ...)`, yang
/// aman jika tombol dibungkus SizedBox/Column (lebar sudah dibatasi
/// parent), tetapi menyebabkan crash
/// `BoxConstraints forces an infinite width` jika tombol ini dipasang
/// langsung di dalam `Row` tanpa Expanded (mis. tombol "Connect" di
/// halaman Setting). Set `fullWidth: false` untuk kasus seperti itu.
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

    // Saat fullWidth = false, override minimumSize width dari theme
    // (yang infinity) menjadi 0 agar tombol menyesuaikan isinya dan
    // aman dipakai di dalam Row.
    final ButtonStyle? buttonStyle = fullWidth
        ? null
        : ButtonStyle(
            minimumSize: WidgetStateProperty.all(
              Size(0, (height ?? AppDimensions.buttonHeight).h),
            ),
          );

    if (primary) {
      return SizedBox(
        height: (height ?? AppDimensions.buttonHeight).h,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: loading ? null : onPressed,
          child: child,
        ),
      );
    }
    return SizedBox(
      height: (height ?? AppDimensions.buttonHeight).h,
      child: OutlinedButton(
        style: buttonStyle,
        onPressed: loading ? null : onPressed,
        child: child,
      ),
    );
  }
}

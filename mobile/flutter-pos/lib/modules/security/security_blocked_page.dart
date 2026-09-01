import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import '../../shared/utils/responsive.dart';
import '../../shared/widgets/glass_panel.dart';

/// Halaman terminal — tidak ada tombol "lanjutkan", tidak ada navigasi
/// balik. Ditampilkan saat DeviceIntegrityService mendeteksi
/// root/jailbreak/emulator di production dan `hardBlock == true`.
class SecurityBlockedPage extends StatelessWidget {
  const SecurityBlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final message = Get.arguments as String? ??
        'Perangkat ini tidak memenuhi standar keamanan untuk menjalankan '
            'aplikasi.';

    return PopScope(
      canPop: false, // cegah back-button menutup halaman blocking ini
      child: Scaffold(
        body: GlassBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(Responsive.padding(context)),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 440.w),
                  child: GlassPanel(
                    radius: AppDimensions.radiusXl,
                    strong: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72.r,
                          height: 72.r,
                          decoration: BoxDecoration(
                            gradient: AppColors.salmonGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.shadowSalmon,
                          ),
                          child: Icon(Icons.shield_outlined, color: Colors.white, size: 36.sp),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Akses Ditolak',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


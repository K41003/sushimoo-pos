import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/splash_controller.dart';

/// REPLACES `splash_page.dart` 1:1 — same class name `SplashPage`.
class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memancing agar lazyPut dari binding aktif dieksekusi
    Get.find<SplashController>();

    return Scaffold(
      body: GlassBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  gradient: AppColors.salmonGradient,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: AppColors.shadowSalmon,
                ),
                child: Icon(Icons.restaurant_menu, size: 44.sp, color: Colors.white),
              ),
              SizedBox(height: 20.h),
              Text('SUSHIMOO', style: Theme.of(context).textTheme.displayLarge),
              SizedBox(height: 8.h),
              Text('Japanese Restaurant POS', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 28.h),
              const CircularProgressIndicator(color: AppColors.salmon),
            ],
          ),
        ),
      ),
    );
  }
}

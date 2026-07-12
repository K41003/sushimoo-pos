import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Memancing agar lazyPut dari binding aktif dieksekusi
    Get.find<SplashController>();

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 90.sp,
              color: scheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'SUSHIMOO',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(height: 8.h),
            Text(
              'Japanese Restaurant POS',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 24.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

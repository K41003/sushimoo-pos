import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/setting_controller.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Setting',
      currentRoute: AppRoutes.setting,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppDimensions.marginTablet.w),
        child: Column(
          children: [
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.print_outlined, color: AppColors.ink, size: 20.sp),
                      SizedBox(width: 12.w),
                      const Text('Thermal Printer'),
                    ],
                  ),
                  Obx(() => AppButton(
                        label: controller.printerConnected.value ? 'Connected' : 'Connect',
                        onPressed: controller.connectPrinter,
                        primary: !controller.printerConnected.value,
                        fullWidth: false,
                      )),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            AppButton(
              label: 'Logout',
              primary: false,
              icon: Icons.logout,
              onPressed: controller.logout,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                  const Text('Dark Theme'),
                  Obx(() => Switch(
                        value: controller.isDark.value,
                        onChanged: controller.toggleTheme,
                      )),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thermal Printer'),
                  Obx(() => AppButton(
                        label: controller.printerConnected.value
                            ? 'Connected'
                            : 'Connect',
                        onPressed: controller.connectPrinter,
                        // FIX: tombol ini ada langsung di dalam Row
                        // (tanpa Expanded), jadi wajib fullWidth:false
                        // supaya tidak kena BoxConstraints infinite width.
                        fullWidth: false,
                      )),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            AppButton(
              label: 'Logout',
              primary: false,
              onPressed: controller.logout,
            ),
          ],
        ),
      ),
    );
  }
}

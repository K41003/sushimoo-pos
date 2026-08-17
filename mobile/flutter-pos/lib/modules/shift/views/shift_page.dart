import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/shift_controller.dart';

/// REPLACES `shift_page.dart` 1:1 — same class name `ShiftPage`.
class ShiftPage extends GetView<ShiftController> {
  const ShiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Shift',
      currentRoute: AppRoutes.shift,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        if (controller.activeShift.value == null) {
          return _openForm(context);
        }
        return _activeView(context);
      }),
    );
  }

  Widget _openForm(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420.w),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Open Shift', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Petty Cash',
                controller: controller.pettyCashController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              Obx(() => AppButton(
                    label: 'Open Shift',
                    loading: controller.loading.value,
                    onPressed: controller.openShift,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activeView(BuildContext context) {
    final shift = controller.activeShift.value!;
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginTablet.w),
      child: Column(
        children: [
          GlassPanel(
            radius: AppDimensions.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Shift #${shift.idShift}', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 8.h),
                Text('Open: ${shift.openTime ?? '-'}'),
                Text('Petty Cash: Rp ${shift.pettyCash.toStringAsFixed(0)}'),
                Text('Status: ${shift.status.toUpperCase()}'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GlassPanel(
            radius: AppDimensions.radiusLg,
            child: Column(
              children: [
                AppTextField(
                  label: 'Add Petty Cash',
                  controller: controller.pettyController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                AppButton(label: 'Record Petty Cash', onPressed: controller.addPettyCash),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppButton(label: 'Close Shift', primary: false, onPressed: controller.closeShift),
        ],
      ),
    );
  }
}

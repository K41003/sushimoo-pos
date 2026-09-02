import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/utils/responsive.dart';
import '../../../app/constants/strings.dart';
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
              Text('Buka Shift',
                  style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 16.h),
              AppTextField(
                label: 'Petty Cash',
                controller: controller.pettyCashController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.h),
              Obx(() => AppButton(
                    label: 'Buka Shift',
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
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: Column(
        children: [
          GlassPanel(
            radius: AppDimensions.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shift Aktif #${shift.idShift}',
                    style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 8.h),
                Text('Dibuka: ${shift.openTime ?? '-'}'),
                Text('Kas Kecil: Rp ${shift.pettyCash.toStringAsFixed(0)}'),
                Text('Status: ${statusLabel(shift.status)}'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          GlassPanel(
            radius: AppDimensions.radiusLg,
            child: Column(
              children: [
                AppTextField(
                  label: 'Tambah Kas Kecil',
                  controller: controller.pettyController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12.h),
                AppButton(
                    label: 'Catat Kas Kecil',
                    onPressed: controller.addPettyCash),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          AppButton(
              label: 'Tutup Shift',
              primary: false,
              onPressed: controller.closeShift),
        ],
      ),
    );
  }
}

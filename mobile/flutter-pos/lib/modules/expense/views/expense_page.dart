import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/expense_controller.dart';

/// REPLACES `expense_page.dart` 1:1 — same class name `ExpensePage`.
class ExpensePage extends GetView<ExpenseController> {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Expense',
      currentRoute: AppRoutes.expense,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        return Stack(
          children: [
            ListView.separated(
              padding: EdgeInsets.all(AppDimensions.marginTablet.w),
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final e = controller.items[i];
                return GlassPanel(
                  radius: AppDimensions.radiusLg,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.kategori, style: Theme.of(context).textTheme.headlineSmall),
                    subtitle: Text(e.keterangan ?? '-', style: Theme.of(context).textTheme.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rp ${e.nominal.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.salmonDark),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => controller.delete(e.idPengeluaran),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: FloatingActionButton(
                onPressed: () => _showForm(context),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showForm(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Expense', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 18.h),
              AppTextField(label: 'Kategori', controller: controller.kategoriController),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'Nominal',
                controller: controller.nominalController,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              AppTextField(label: 'Keterangan', controller: controller.keteranganController),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: () => Get.back(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppButton(label: 'Save', onPressed: controller.save),
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

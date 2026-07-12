import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/expense_controller.dart';

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
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (_, i) {
                final e = controller.items[i];
                return AppCard(
                  child: ListTile(
                    title: Text(e.kategori),
                    subtitle: Text(e.keterangan ?? '-'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rp ${e.nominal.toStringAsFixed(0)}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
      AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(label: 'Kategori', controller: controller.kategoriController),
            SizedBox(height: 12.h),
            AppTextField(
              label: 'Nominal',
              controller: controller.nominalController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              label: 'Keterangan',
              controller: controller.keteranganController,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          AppButton(label: 'Save', onPressed: controller.save),
        ],
      ),
    );
  }
}

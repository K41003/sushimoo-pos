import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
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
      actions: [
        AppGlassActionButton(
          icon: Icons.add,
          tooltip: 'Add Expense',
          onPressed: () => _showForm(context),
        ),
      ],
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        if (controller.items.isEmpty) {
          return const AppEmptyState(message: 'No expenses recorded');
        }
        return ListView.separated(
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
        );
      }),
    );
  }

  void _showForm(BuildContext context) {
    AppDialog.form(
      title: 'Add Expense',
      icon: Icons.receipt_long_rounded,
      maxWidth: 420.w,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(label: 'Kategori', controller: controller.kategoriController),
          SizedBox(height: 14.h),
          AppTextField(
            label: 'Nominal',
            controller: controller.nominalController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 14.h),
          AppTextField(label: 'Keterangan', controller: controller.keteranganController),
        ],
      ),
      onConfirm: () async {
        await controller.save();
        return false; // controller.save handles closing
      },
    );
  }
}

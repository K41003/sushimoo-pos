import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/stock_controller.dart';

/// REPLACES `stock_page.dart` 1:1 — same class name `StockPage`.
class StockPage extends GetView<StockController> {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stock',
      currentRoute: AppRoutes.stock,
      actions: [
        SizedBox(
          width: 220.w,
          child: AppTextField(
            hint: 'Search...',
            onChanged: controller.setSearch,
          ),
        ),
      ],
      body: Stack(
        children: [
          Obx(() {
            if (controller.loading.value) return const AppLoading();
            if (controller.items.isEmpty) {
              return const AppEmptyState(message: 'No stock found');
            }
            return ListView.separated(
              padding: EdgeInsets.all(AppDimensions.marginTablet.w),
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final it = controller.items[i];
                final name = it.ingredient?.namaBahan ?? '-';
                return GlassPanel(
                  radius: AppDimensions.radiusLg,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: Theme.of(context).textTheme.headlineSmall),
                            SizedBox(height: 4.h),
                            Text(
                              '${it.jumlah} ${it.ingredient?.satuan ?? ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => controller.adjust(it),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.danger,
                        onPressed: () => controller.delete(it.idStok),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          Positioned(
            right: 16.w,
            bottom: 16.h,
            child: FloatingActionButton(
              onPressed: controller.addAdjustment,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

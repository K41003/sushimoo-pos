import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/utils/responsive.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/stock_controller.dart';

/// REPLACES `stock_page.dart` 1:1 — same class name `StockPage`.
class StockPage extends GetView<StockController> {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stok',
      currentRoute: AppRoutes.stock,
      actions: [
        AppHeaderSearchField(
          hint: 'Cari stok...',
          width: 170.w,
          onChanged: controller.setSearch,
        ),
        AppGlassActionButton(
          icon: Icons.add,
          tooltip: 'Tambah Penyesuaian',
          onPressed: controller.addAdjustment,
        ),
      ],
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        if (controller.items.isEmpty) {
          return const AppEmptyState(message: 'Belum ada data stok');
        }
        return ListView.separated(
          padding: EdgeInsets.all(Responsive.padding(context)),
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
                        Text(name,
                            style: Theme.of(context).textTheme.headlineSmall),
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
    );
  }
}

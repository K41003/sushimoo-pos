import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card_widget.dart';

/// REPLACES `product_page.dart` 1:1 — same class name `ProductPage`,
/// same `GetView<ProductController>`.
class ProductPage extends GetView<ProductController> {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Produk',
      currentRoute: AppRoutes.product,
      actions: [
        AppGlassActionButton(
          icon: Icons.add,
          tooltip: 'Tambah Produk',
          onPressed: () => controller.openForm(null),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(Responsive.padding(context)),
        child: Column(
          children: [
            AppHeaderSearchField(
              hint: 'Cari produk...',
              onChanged: controller.onSearchChanged,
            ),
            SizedBox(height: 12.h),
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppChip(
                        label: 'Semua',
                        selected: controller.selectedCategoryId.value == null,
                        onTap: () => controller.selectCategory(null),
                      ),
                      SizedBox(width: 8.w),
                      ...controller.categories.map(
                        (c) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: AppChip(
                            label: c.namaKategori,
                            selected: controller.selectedCategoryId.value ==
                                c.idKategori,
                            onTap: () =>
                                controller.selectCategory(c.idKategori),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const AppLoading(message: 'Memuat produk...');
                }
                if (controller.items.isEmpty) {
                  return const AppEmptyState(message: 'Belum ada produk');
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final cols = Responsive.columnsForWidth(
                      availableWidth,
                      itemMinWidth: 170.0,
                      min: 2,
                      max: 5,
                    );
                    final tileWidth = (availableWidth - (cols - 1) * 14.w) / cols;
                    final tileHeight = (tileWidth * 1.15).clamp(180.0, 240.0);
                    final childAspectRatio = tileWidth / tileHeight;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 14.w,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        final p = controller.items[index];
                        return ProductCardWidget(
                          product: p,
                          onTap: () => controller.openForm(p),
                          onDelete: () => controller.delete(p.idProduk),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

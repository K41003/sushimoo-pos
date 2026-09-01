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
        AppHeaderSearchField(
          hint: 'Cari produk...',
          width: 180.w,
          onChanged: controller.onSearchChanged,
        ),
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
                // Fixed column count per Responsive breakpoint tier,
                // replacing the previous `maxCrossAxisExtent: 240.w` —
                // that extent was computed against the tablet-landscape
                // design size, so on a narrow phone it silently produced
                // more/smaller columns than intended instead of a clean
                // 2-column phone grid.
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.gridColumns(context, max: 5),
                    mainAxisSpacing: 14.h,
                    crossAxisSpacing: 14.w,
                    childAspectRatio: 1.1,
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
              }),
            ),
          ],
        ),
      ),
    );
  }
}

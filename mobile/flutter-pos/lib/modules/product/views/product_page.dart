import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
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
      title: 'Product',
      currentRoute: AppRoutes.product,
      actions: [
        AppHeaderSearchField(
          hint: 'Search product...',
          width: 180.w,
          onChanged: controller.onSearchChanged,
        ),
        AppGlassActionButton(
          icon: Icons.add,
          tooltip: 'Add Product',
          onPressed: () => controller.openForm(null),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppChip(
                        label: 'All',
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
                  return const AppLoading(message: 'Loading products...');
                }
                if (controller.items.isEmpty) {
                  return const AppEmptyState(message: 'No products found');
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240.w,
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

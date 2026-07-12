import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/product_controller.dart';
import '../widgets/product_card_widget.dart';

class ProductPage extends GetView<ProductController> {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Product',
      currentRoute: AppRoutes.product,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => controller.openForm(null),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            AppTextField(
              label: 'Search',
              hint: 'Search product...',
              onChanged: controller.onSearchChanged,
            ),
            SizedBox(height: 16.h),
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
                            selected:
                                controller.selectedCategoryId.value ==
                                    c.idKategori,
                            onTap: () => controller.selectCategory(c.idKategori),
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
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
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

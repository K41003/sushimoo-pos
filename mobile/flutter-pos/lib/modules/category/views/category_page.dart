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
import '../controllers/category_controller.dart';

/// REPLACES `category_page.dart` 1:1 — same class name `CategoryPage`,
/// same `GetView<CategoryController>`. Zero controller/binding changes.
class CategoryPage extends GetView<CategoryController> {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Category',
      currentRoute: AppRoutes.category,
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
              hint: 'Search category...',
              onChanged: controller.onSearchChanged,
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const AppLoading(message: 'Loading categories...');
                }
                if (controller.items.isEmpty) {
                  return const AppEmptyState(message: 'No categories found');
                }
                return ListView.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final c = controller.items[index];
                    return GlassPanel(
                      radius: AppDimensions.radiusLg,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.namaKategori,
                                    style: Theme.of(context).textTheme.headlineSmall),
                                if (c.deskripsi != null && c.deskripsi!.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(c.deskripsi!, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: c.status
                                  ? AppColors.emerald.withValues(alpha: 0.14)
                                  : AppColors.danger.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(
                              c.status ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: c.status ? Colors.green.shade800 : Colors.red.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => controller.openForm(c),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppColors.danger,
                            onPressed: () => controller.delete(c.idKategori),
                          ),
                        ],
                      ),
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

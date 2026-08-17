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
import '../controllers/ingredient_controller.dart';

/// REPLACES `ingredient_page.dart` 1:1 — same class name `IngredientPage`.
class IngredientPage extends GetView<IngredientController> {
  const IngredientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ingredient',
      currentRoute: AppRoutes.ingredient,
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
              return const AppEmptyState(message: 'No ingredients found');
            }
            return ListView.separated(
              padding: EdgeInsets.all(AppDimensions.marginTablet.w),
              itemCount: controller.items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final it = controller.items[i];
                return GlassPanel(
                  radius: AppDimensions.radiusLg,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it.namaBahan, style: Theme.of(context).textTheme.headlineSmall),
                            SizedBox(height: 4.h),
                            Text(
                              '${it.satuan} • Min ${it.minimalStok}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => controller.save(it),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.danger,
                        onPressed: () => controller.delete(it.idBahan),
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
              onPressed: () => controller.save(null),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/table.dart' as tm;
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/table_controller.dart';

/// REPLACES `table_page.dart` 1:1 — same class name `TablePage`.
class TablePage extends GetView<TableController> {
  const TablePage({super.key});

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return 5;
    if (w > 900) return 4;
    if (w > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Table',
      currentRoute: AppRoutes.table,
      body: Stack(
        children: [
          Obx(() {
            if (controller.loading.value) return const AppLoading();
            return Column(
              children: [
                SizedBox(height: 12.h),
                _filterChips(context),
                Expanded(
                  child: controller.items.isEmpty
                      ? const AppEmptyState(message: 'No tables found')
                      : GridView.builder(
                          padding: EdgeInsets.all(AppDimensions.marginTablet.w),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _crossAxisCount(context),
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: controller.items.length,
                          itemBuilder: (_, i) => _tableCard(context, controller.items[i]),
                        ),
                ),
              ],
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

  Widget _filterChips(BuildContext context) {
    final options = ['', ...controller.statusOptions];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginTablet.w),
      child: Row(
        children: options.map((s) {
          final label = s.isEmpty ? 'All' : s;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Obx(() => AppChip(
                  label: label,
                  selected: controller.statusFilter.value == s,
                  onTap: () => controller.setStatusFilter(s),
                )),
          );
        }).toList(),
      ),
    );
  }

  Widget _tableCard(BuildContext context, tm.TableModel t) {
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      onTap: () => controller.save(t),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Meja ${t.nomorMeja}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text('${t.kapasitas} seats', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 10.h),
              StatusChip(status: t.status),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.delete, size: 18.sp, color: AppColors.danger),
              onPressed: () => controller.delete(t.idMeja),
            ),
          ),
        ],
      ),
    );
  }
}

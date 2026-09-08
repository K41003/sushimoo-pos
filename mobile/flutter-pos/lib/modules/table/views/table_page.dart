import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/constants/strings.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/table.dart' as tm;
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/table_controller.dart';

/// REPLACES `table_page.dart` 1:1 — same class name `TablePage`.
class TablePage extends GetView<TableController> {
  const TablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Meja',
      currentRoute: AppRoutes.table,
      actions: [
        AppGlassActionButton(
          icon: Icons.add,
          tooltip: 'Tambah Meja',
          onPressed: () => controller.save(null),
        ),
      ],
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
                      ? const AppEmptyState(message: 'Belum ada meja')
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth - (Responsive.padding(context) * 2);
                            final cols = Responsive.columnsForWidth(
                              availableWidth,
                              itemMinWidth: 160.0,
                              min: 2,
                              max: 5,
                            );
                            final tileWidth = (availableWidth - (cols - 1) * 12.w) / cols;
                             final tileHeight = (tileWidth * 1.05).clamp(135.0, 160.0);
                            final childAspectRatio = tileWidth / tileHeight;

                            return GridView.builder(
                              padding: EdgeInsets.all(Responsive.padding(context)),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: controller.items.length,
                              itemBuilder: (_, i) => _tableCard(context, controller.items[i]),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    final options = ['', ...controller.statusOptions];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: Responsive.padding(context)),
      child: Row(
        children: options.map((s) {
          // `s` is the internal status value (available/occupied/...);
          // show its Indonesian label, not the raw key, while the
          // comparison/filter logic below still uses the raw `s`.
          final label = s.isEmpty ? 'Semua' : statusLabel(s);
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
      padding: EdgeInsets.fromLTRB(10.w, 4.h, 6.w, 8.h),
      onTap: () => controller.save(t),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => controller.delete(t.idMeja),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(Icons.delete_outline, size: 16.sp, color: AppColors.danger),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Meja ${t.nomorMeja}',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text('${t.kapasitas} kursi', style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 6.h),
                    StatusChip(status: t.status),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

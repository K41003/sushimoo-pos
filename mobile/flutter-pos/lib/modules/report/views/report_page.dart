import 'package:fl_chart/fl_chart.dart';
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
import '../controllers/report_controller.dart';
import '../../../shared/utils/money.dart';

/// REPLACES `report_page.dart` 1:1 — same class name `ReportPage`.
class ReportPage extends GetView<ReportController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Laporan',
      currentRoute: AppRoutes.report,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        return SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  if (!isWide) {
                    return Column(
                      children: [
                        _card('Penjualan Hari Ini', controller.daily['sales'] ?? 0),
                        SizedBox(height: 10.h),
                        _card('Order Hari Ini', controller.daily['orders'] ?? 0, isCurrency: false),
                        SizedBox(height: 10.h),
                        _card('Tunai Hari Ini', controller.daily['cash'] ?? 0),
                        SizedBox(height: 10.h),
                        _card('QRIS Hari Ini', controller.daily['qris'] ?? 0),
                        SizedBox(height: 10.h),
                        _card('Pengeluaran Hari Ini', controller.daily['expenses'] ?? 0),
                      ],
                    );
                  }
                  final halfWidth = (constraints.maxWidth - 12.w) / 2;
                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 10.h,
                    children: [
                      SizedBox(width: halfWidth, child: _card('Penjualan Hari Ini', controller.daily['sales'] ?? 0)),
                      SizedBox(width: halfWidth, child: _card('Order Hari Ini', controller.daily['orders'] ?? 0, isCurrency: false)),
                      SizedBox(width: halfWidth, child: _card('Tunai Hari Ini', controller.daily['cash'] ?? 0)),
                      SizedBox(width: halfWidth, child: _card('QRIS Hari Ini', controller.daily['qris'] ?? 0)),
                      SizedBox(width: halfWidth, child: _card('Pengeluaran Hari Ini', controller.daily['expenses'] ?? 0)),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),
              GlassPanel(
                radius: AppDimensions.radiusLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7 Hari Terakhir', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 12.h),
                    SizedBox(height: 240.h, child: _barChart()),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _card(String label, dynamic value, {bool isCurrency = true}) {
    final numVal = value is num ? value : (num.tryParse(value?.toString() ?? '') ?? 0);
    final textValue = isCurrency
        ? formatRupiah(numVal)
        : numVal.toStringAsFixed(0);
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      padding: EdgeInsets.all(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
          Text(textValue,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.salmonDark)),
        ],
      ),
    );
  }

  Widget _barChart() {
    final days = (controller.last7['days'] as List? ?? List.filled(7, '')).cast<String>();
    final totals = (controller.last7['totals'] as List? ?? List.filled(7, 0))
        .map((e) => (e is num ? e : 0).toDouble())
        .toList();
    if (days.isEmpty) return const Center(child: Text('Belum ada data'));
    final spots = totals.asMap().entries.map((e) {
      return BarChartRodData(toY: e.value, width: 18, color: AppColors.salmon, borderRadius: BorderRadius.circular(6));
    }).toList();
    return BarChart(BarChartData(
      barGroups: spots.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [e.value])).toList(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) =>
                Text(days[v.toInt()].substring(5, 10), style: const TextStyle(fontSize: 10)),
          ),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/report_controller.dart';

class ReportPage extends GetView<ReportController> {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Report',
      currentRoute: AppRoutes.report,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        return SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.marginTablet.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card('Daily Sales', controller.daily['sales'] ?? 0),
              _card('Daily Orders', controller.daily['orders'] ?? 0),
              _card('Daily Cash', controller.daily['cash'] ?? 0),
              _card('Daily QRIS', controller.daily['qris'] ?? 0),
              _card('Daily Expenses', controller.daily['expenses'] ?? 0),
              SizedBox(height: 24.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last 7 Days',
                          style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: 12.h),
                      SizedBox(height: 240.h, child: _barChart()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _card(String label, dynamic value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Rp ${(value is num ? value : 0).toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _barChart() {
    final days = (controller.last7['days'] as List? ??
        List.filled(7, '')).cast<String>();
    final totals = (controller.last7['totals'] as List? ?? List.filled(7, 0))
        .map((e) => (e is num ? e : 0).toDouble())
        .toList();
    if (days.isEmpty) return const Center(child: Text('No data'));
    final spots = totals
        .asMap()
        .entries
        .map((e) => BarChartRodData(toY: e.value, width: 18))
        .toList();
    return BarChart(BarChartData(
      barGroups: spots
          .asMap()
          .entries
          .map((e) => BarChartGroupData(x: e.key, barRods: [e.value]))
          .toList(),
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

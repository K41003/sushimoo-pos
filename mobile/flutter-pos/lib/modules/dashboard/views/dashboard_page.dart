import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      currentRoute: AppRoutes.dashboard,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        return controller.isAdmin.value
            ? _admin(context)
            : _cashier(context);
      }),
    );
  }

  Widget _admin(BuildContext context) {
    final d = controller.adminData;
    final trend = (d['salesTrend'] as Map? ?? {});
    final top = (d['topProducts'] as List? ?? []);
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginTablet.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.6,
            children: [
              StatCard(label: 'Total Sales',
                  value: _money(d['totalSales']), icon: Icons.payments),
              StatCard(label: 'Transactions',
                  value: '${d['transactions'] ?? 0}', icon: Icons.receipt_long),
              StatCard(label: 'Products',
                  value: '${d['products'] ?? 0}', icon: Icons.fastfood),
              StatCard(label: 'Expenses',
                  value: _money(d['expenses']), icon: Icons.money_off),
            ],
          ),
          SizedBox(height: 24.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales Trend', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 12.h),
                  SizedBox(height: 220.h, child: _trendChart(trend)),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Products', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 12.h),
                  ...top.map((p) => ListTile(
                        title: Text(p['nama_produk']?.toString() ?? '-'),
                        trailing: Text('${p['qty']}'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cashier(BuildContext context) {
    final d = controller.cashierData;
    final shift = d['currentShift'];
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginTablet.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1.6,
            children: [
              StatCard(label: 'Current Shift',
                  value: shift != null ? '#${shift['id_shift']}' : 'None',
                  icon: Icons.schedule),
              StatCard(label: 'Sales Today',
                  value: _money(d['salesToday']), icon: Icons.payments),
              StatCard(label: 'Orders Today',
                  value: '${d['ordersToday'] ?? 0}', icon: Icons.receipt_long),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Open Shift',
                  icon: Icons.login,
                  onPressed: () => Get.toNamed(AppRoutes.shift),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AppButton(
                  label: 'Go to POS',
                  icon: Icons.point_of_sale,
                  onPressed: () => Get.toNamed(AppRoutes.pos),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _trendChart(Map trend) {
    final entries = trend.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No data'));
    }
    final spots = entries.asMap().entries.map((e) {
      final v = (e.value.value as num).toDouble();
      return FlSpot(e.key.toDouble(), v);
    }).toList();
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  String _money(dynamic v) =>
      'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';
}

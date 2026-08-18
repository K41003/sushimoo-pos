import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/stat_card.dart';

/// REPLACES `dashboard_page.dart` 1:1 — same class name `DashboardPage`,
/// same `GetView<DashboardController>`, so `DashboardBinding` and
/// `app_pages.dart` need zero changes. Visual layer rebuilt as
/// Glassmorphic Zen.
///
/// FIX: this previously used a bare `Scaffold` instead of `AppScaffold`,
/// which meant Dashboard had no sidebar (landscape tablet) and no drawer
/// / hamburger button (phone/portrait) — the user was stuck with no way
/// to navigate away or log out. Now routed through `AppScaffold` like
/// every other page, so it gets the same rail/drawer + logout button.
///
/// BUG FIX (2026-08-17): `/dashboard/admin` can return `salesTrend` as
/// EITHER a keyed map (`{"2026-08-10": 120000, ...}`) OR a list of
/// `{date, total}` objects (`[{"date": "2026-08-10", "total": 120000}]`),
/// depending on how the Laravel controller serializes its `groupBy()`
/// result (whether `->values()` was called downstream). The previous
/// code did `(d['salesTrend'] as Map? ?? {})`, which throws
/// `type 'List<dynamic>' is not a subtype of type 'Map<dynamic, dynamic>?'`
/// whenever the backend sends the list form — this crashed the entire
/// Admin Dashboard on load. `normalizeTrend()` now accepts both shapes
/// and always hands back a `Map<String, num>`, so the page renders
/// regardless of which shape the API returns.
class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      currentRoute: AppRoutes.dashboard,
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.salmon));
        }
        return controller.isAdmin.value ? _admin(context) : _cashier(context);
      }),
    );
  }

  Widget _admin(BuildContext context) {
    final d = controller.adminData;
    final trend = normalizeTrend(d['salesTrend']);
    final top = (d['topProducts'] as List? ?? []);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.marginTablet.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 'Dashboard', 'Ringkasan performa hari ini'),
          SizedBox(height: 24.h),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 560 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  label: 'Total Sales',
                  value: _money(d['totalSales']),
                  icon: Icons.payments_outlined,
                  trend: '+12%',
                ),
                StatCard(
                  label: 'Transactions',
                  value: '${d['transactions'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                  accent: const Color(0xFF2F6FED),
                ),
                StatCard(
                  label: 'Products',
                  value: '${d['products'] ?? 0}',
                  icon: Icons.fastfood_outlined,
                  accent: AppColors.emerald,
                ),
                StatCard(
                  label: 'Expenses',
                  value: _money(d['expenses']),
                  icon: Icons.money_off_outlined,
                  accent: AppColors.danger,
                ),
              ],
            );
          }),
          SizedBox(height: 24.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales Trend', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 12.h),
                SizedBox(height: 220.h, child: _trendChart(trend)),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Products', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 12.h),
                ...top.map((p) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 34.r,
                            height: 34.r,
                            decoration: BoxDecoration(
                              color: AppColors.salmonSoft,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.ramen_dining_outlined,
                                size: 17.sp, color: AppColors.salmonDark),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              p['nama_produk']?.toString() ?? '-',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          Text('${p['qty']}x', style: Theme.of(context).textTheme.labelLarge),
                        ],
                      ),
                    )),
                if (top.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text('No data available', style: Theme.of(context).textTheme.bodyMedium),
                  ),
              ],
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
          _header(context, 'Selamat Bekerja', 'Ringkasan shift kamu hari ini'),
          SizedBox(height: 24.h),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 700 ? 3 : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  label: 'Current Shift',
                  value: shift != null ? '#${shift['id_shift']}' : 'None',
                  icon: Icons.schedule_outlined,
                  accent: const Color(0xFF2F6FED),
                ),
                StatCard(
                  label: 'Sales Today',
                  value: _money(d['salesToday']),
                  icon: Icons.payments_outlined,
                ),
                StatCard(
                  label: 'Orders Today',
                  value: '${d['ordersToday'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                  accent: AppColors.emerald,
                ),
              ],
            );
          }),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Open Shift',
                  icon: Icons.login,
                  primary: false,
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

  Widget _header(BuildContext context, String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28.sp)),
              SizedBox(height: 4.h),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        GlassPanel(
          radius: 14.r,
          padding: EdgeInsets.zero,
          blurSigma: AppColors.blurSigmaLight,
          shadow: AppColors.shadowSm,
          child: SizedBox(
            width: 44.r,
            height: 44.r,
            child: Icon(Icons.notifications_outlined, size: 20.sp, color: AppColors.ink),
          ),
        ),
      ],
    );
  }

  Widget _trendChart(Map<String, num> trend) {
    final entries = trend.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('No data'));
    }
    final spots = entries.asMap().entries.map((e) {
      final v = e.value.value.toDouble();
      return FlSpot(e.key.toDouble(), v);
    }).toList();
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          barWidth: 3,
          color: AppColors.salmon,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.salmon.withValues(alpha: 0.25),
                AppColors.salmon.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
    ));
  }

  String _money(dynamic v) => 'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';
}

/// Normalizes the `salesTrend` field from `/dashboard/admin` into a
/// consistent `Map<String, num>` regardless of which shape the backend
/// returns:
///
///  - Map form:  `{"2026-08-10": 120000, "2026-08-11": 95000}`
///  - List form: `[{"date": "2026-08-10", "total": 120000}, ...]`
///
/// Root cause: Laravel's `groupBy()` can be re-indexed with `->values()`
/// (producing a JSON array) or left keyed (producing a JSON object)
/// depending on the exact query chain used in the controller. Rather
/// than relying on the backend contract never drifting, the client
/// accepts both shapes so a backend-side serialization change doesn't
/// crash the Dashboard.
///
/// Unknown/malformed entries are skipped rather than thrown; missing or
/// null input returns an empty map so downstream widgets fall back to
/// their "No data" empty state.
Map<String, num> normalizeTrend(dynamic raw) {
  if (raw == null) return {};

  if (raw is Map) {
    final out = <String, num>{};
    raw.forEach((key, value) {
      out[key.toString()] = _toNum(value);
    });
    return out;
  }

  if (raw is List) {
    final out = <String, num>{};
    for (final item in raw) {
      if (item is Map) {
        final key = (item['date'] ?? item['label'] ?? item['tanggal'] ?? '').toString();
        final value = item['total'] ?? item['value'] ?? item['sales'] ?? 0;
        out[key] = _toNum(value);
      }
    }
    return out;
  }

  return {};
}

num _toNum(dynamic v) {
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}

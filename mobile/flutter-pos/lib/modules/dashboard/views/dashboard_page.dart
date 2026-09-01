import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/utils/responsive.dart';
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
/// result (whether `->values()` was called downstream). `normalizeTrend()`
/// accepts both shapes and always hands back a `Map<String, num>`, so the
/// page renders regardless of which shape the API returns.
///
/// UI FIX (this pass): the "Total Sales" stat card used to show a
/// hardcoded `trend: '+12%'` badge that had no relationship to any real
/// data returned by the API — it was the same fake number regardless of
/// what actually happened this period. Showing a made-up percentage next
/// to a real sales figure is misleading for whoever is reading the
/// dashboard (an admin might genuinely believe sales grew 12%). The badge
/// is now computed from the real `salesTrend` series (comparing the last
/// two data points) and only renders when there's enough real data to
/// support a percentage; otherwise it's omitted entirely rather than
/// showing a placeholder number.
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
    final salesTrendLabel = _trendLabel(trend);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 'Dashboard', 'Ringkasan performa hari ini'),
          SizedBox(height: AppDimensions.xl.h),
          LayoutBuilder(builder: (context, constraints) {
            // Reads the *content area* width (post-sidebar, if any) via
            // LayoutBuilder rather than MediaQuery, so this stays
            // accurate on the landscape-tablet rail layout too — but the
            // breakpoints themselves now match Responsive.wideBreakpoint
            // / tabletBreakpoint instead of the ad-hoc 900/560 values
            // this previously used (which had no 3-column tier at all,
            // jumping straight from 1 to 2 to 4).
            final w = constraints.maxWidth;
            final cols = w >= Responsive.wideBreakpoint
                ? 4
                : w >= 700
                    ? 3
                    : w >= 420
                        ? 2
                        : 1;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: AppDimensions.md.w,
              mainAxisSpacing: AppDimensions.md.h,
              childAspectRatio: 1.5,
              children: [
                StatCard(
                  label: 'Total Penjualan',
                  value: _money(d['totalSales']),
                  icon: Icons.payments_outlined,
                  trend: salesTrendLabel,
                ),
                StatCard(
                  label: 'Transaksi',
                  value: '${d['transactions'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                  accent: const Color(0xFF2F6FED),
                ),
                StatCard(
                  label: 'Produk',
                  value: '${d['products'] ?? 0}',
                  icon: Icons.fastfood_outlined,
                  accent: AppColors.emerald,
                ),
                StatCard(
                  label: 'Pengeluaran',
                  value: _money(d['expenses']),
                  icon: Icons.money_off_outlined,
                  accent: AppColors.danger,
                ),
              ],
            );
          }),
          SizedBox(height: AppDimensions.xl.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tren Penjualan', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: AppDimensions.sm.h),
                SizedBox(height: 220.h, child: _trendChart(trend)),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.xl.h),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Produk Terlaris', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: AppDimensions.sm.h),
                ...top.map((p) => Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimensions.xs.h),
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
                          SizedBox(width: AppDimensions.sm.w),
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
                    padding: EdgeInsets.symmetric(vertical: AppDimensions.sm.h),
                    child: Text('Belum ada data', style: Theme.of(context).textTheme.bodyMedium),
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
      padding: EdgeInsets.all(Responsive.padding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 'Selamat Bekerja', 'Ringkasan shift kamu hari ini'),
          SizedBox(height: AppDimensions.xl.h),
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w >= 700 ? 3 : (w >= 420 ? 2 : 1);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: AppDimensions.md.w,
              mainAxisSpacing: AppDimensions.md.h,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  label: 'Shift Aktif',
                  value: shift != null ? '#${shift['id_shift']}' : 'Tidak ada',
                  icon: Icons.schedule_outlined,
                  accent: const Color(0xFF2F6FED),
                ),
                StatCard(
                  label: 'Penjualan Hari Ini',
                  value: _money(d['salesToday']),
                  icon: Icons.payments_outlined,
                ),
                StatCard(
                  label: 'Order Hari Ini',
                  value: '${d['ordersToday'] ?? 0}',
                  icon: Icons.receipt_long_outlined,
                  accent: AppColors.emerald,
                ),
              ],
            );
          }),
          SizedBox(height: AppDimensions.xl.h),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Buka Shift',
                  icon: Icons.login,
                  primary: false,
                  onPressed: () => Get.toNamed(AppRoutes.shift),
                ),
              ),
              SizedBox(width: AppDimensions.md.w),
              Expanded(
                child: AppButton(
                  label: 'Ke Kasir',
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

  /// UI CHANGE: the notification bell icon that used to sit here was
  /// purely decorative — it wasn't wired to any notification feature
  /// (no badge count, no tap handler beyond nothing, no backing data).
  /// Showing an icon that looks interactive but does nothing on tap is
  /// misleading, so the header is now just the title/subtitle block.
  Widget _header(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28.sp)),
        SizedBox(height: 4.h),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _trendChart(Map<String, num> trend) {
    final entries = trend.entries.toList();
    if (entries.isEmpty) {
      return const Center(child: Text('Belum ada data'));
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

  /// Computes a "+X%" / "-X%" label by comparing the last two points of
  /// the real sales trend series. Returns null (no badge shown) when
  /// there isn't enough data to make a meaningful comparison, or when
  /// the previous point is zero (percentage change is undefined).
  String? _trendLabel(Map<String, num> trend) {
    final values = trend.values.toList();
    if (values.length < 2) return null;
    final previous = values[values.length - 2];
    final latest = values.last;
    if (previous == 0) return null;
    final change = ((latest - previous) / previous) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(0)}%';
  }
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

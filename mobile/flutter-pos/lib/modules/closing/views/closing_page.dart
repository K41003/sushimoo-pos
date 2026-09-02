import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/utils/responsive.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/closing.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/closing_controller.dart';

/// REPLACES `closing_page.dart` 1:1 — same class name `ClosingPage`.
///
/// BUG FIX: "Closing Kasir" used to require `activeShift.value != null`
/// server AND client side, but a shift closed from the Shift page's
/// "Close Shift" button leaves `activeShift` null by the time the cashier
/// gets here — so the button stayed permanently disabled and there was
/// no way to view/print the report that had already been generated. Now
/// that `/shifts/{id}/closing` is idempotent (see `ClosingController`),
/// the button stays enabled whenever there's an active shift OR a report
/// already exists to (re)print, and every report card in history gets
/// its own "Print" action.
class ClosingPage extends GetView<ClosingController> {
  const ClosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Tutup Shift',
      currentRoute: AppRoutes.closing,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        final shift = controller.activeShift.value;
        final hasReportToShow = controller.lastClosing.value != null;

        return SingleChildScrollView(
          padding: EdgeInsets.all(Responsive.padding(context)),
          child: Column(
            children: [
              GlassPanel(
                radius: AppDimensions.radiusLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shift Aktif',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text(shift != null
                        ? 'Shift #${shift.idShift} sedang berjalan'
                        : 'Tidak ada shift aktif'),
                    SizedBox(height: 16.h),
                    AppButton(
                      label: 'Tutup Shift',
                      primary: shift != null,
                      onPressed:
                          shift != null ? () => controller.doClosing() : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              if (hasReportToShow)
                _reportCard(context, controller.lastClosing.value!, controller,
                    highlight: true),
              SizedBox(height: 16.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Riwayat Tutup Kasir',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
              SizedBox(height: 8.h),
              if (controller.history.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Text(
                    'Belum ada laporan tutup kasir.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...controller.history.map((c) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _reportCard(context, c, controller),
                    )),
            ],
          ),
        );
      }),
    );
  }

  Widget _reportCard(
    BuildContext context,
    Closing c,
    ClosingController controller, {
    bool highlight = false,
  }) {
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      strong: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tutup Kasir #${c.idClosing}',
                  style: Theme.of(context).textTheme.bodyLarge),
              Obx(() => IconButton(
                    tooltip: 'Cetak laporan',
                    icon: controller.printing.value
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.salmon),
                          )
                        : const Icon(Icons.print_outlined,
                            color: AppColors.salmon),
                    onPressed: controller.printing.value
                        ? null
                        : () => controller.printReport(c),
                  )),
            ],
          ),
          SizedBox(height: 6.h),
          Text('Total Penjualan: Rp ${c.totalPenjualan.toStringAsFixed(0)}'),
          Text('Total Tunai: Rp ${c.totalCash.toStringAsFixed(0)}'),
          Text('Total QRIS: Rp ${c.totalQris.toStringAsFixed(0)}'),
          Text(
              'Total Pengeluaran: Rp ${c.totalPengeluaran.toStringAsFixed(0)}'),
          Text('Saldo Akhir: Rp ${c.saldoAkhir.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

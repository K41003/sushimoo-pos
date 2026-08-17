import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/receipt_controller.dart';

/// REPLACES `receipt_page.dart` 1:1 — same class name `ReceiptPage`,
/// same `GetView<ReceiptController>`.
class ReceiptPage extends GetView<ReceiptController> {
  const ReceiptPage({super.key});

  String _money(num v) => 'Rp ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = controller.transaction;
    final pay = controller.payment;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Receipt View', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginTablet.w, vertical: 16.h),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 440.w),
                      child: Column(
                        children: [
                          GlassPanel(
                            radius: 20,
                            strong: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: AppColors.emerald, size: 16.sp),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'PAYMENT SUCCESSFUL',
                                          style: TextStyle(
                                            color: AppColors.emerald,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'SUSHIMOO',
                                        style: TextStyle(
                                          fontFamily: 'Serif',
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.5,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Zen Japanese Dining',
                                        style: TextStyle(fontSize: 11.sp, color: AppColors.inkMuted, letterSpacing: 1),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Grand Indonesia Mall, Lt. 3 • Jakarta',
                                        style: TextStyle(fontSize: 10.sp, color: AppColors.inkFaint),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                _buildDashedDivider(),
                                SizedBox(height: 16.h),
                                _buildReceiptRow('Invoice', trx.invoiceNumber, isMonospace: true),
                                _buildReceiptRow('Tanggal',
                                    trx.tanggal.substring(0, trx.tanggal.length > 16 ? 16 : trx.tanggal.length)),
                                _buildReceiptRow(
                                    'Table / Layanan', trx.table?.nomorMeja != null ? 'Meja ${trx.table!.nomorMeja}' : 'Takeaway'),
                                SizedBox(height: 8.h),
                                _buildDashedDivider(),
                                SizedBox(height: 16.h),
                                Text('ITEMS ORDERED',
                                    style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5)),
                                SizedBox(height: 10.h),
                                ...?trx.details?.map(
                                  (d) => Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${d.qty}x ',
                                            style: TextStyle(
                                                fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.ink)),
                                        Expanded(
                                          child: Text(
                                            d.product?.namaProduk ?? 'Item #${d.idProduk}',
                                            style: TextStyle(fontFamily: 'Courier', fontSize: 14.sp, color: AppColors.ink),
                                          ),
                                        ),
                                        Text(_money(d.subtotal),
                                            style: TextStyle(fontFamily: 'Courier', fontSize: 14.sp, color: AppColors.ink)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                _buildDashedDivider(),
                                SizedBox(height: 16.h),
                                _buildReceiptRow('Subtotal', _money(controller.subtotal), isMonospace: true),
                                _buildReceiptRow('Pajak (10%)', _money(controller.tax), isMonospace: true),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('TOTAL BILL:', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.ink)),
                                    Text(_money(trx.total),
                                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: AppColors.salmonDark)),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                _buildDashedDivider(),
                                SizedBox(height: 16.h),
                                _buildReceiptRow('Metode Bayar', pay.method?.namaMetode ?? pay.status.toUpperCase()),
                                _buildReceiptRow('Uang Diterima', _money(pay.uangDiterima), isMonospace: true),
                                _buildReceiptRow('Uang Kembalian', _money(pay.kembalian), isMonospace: true, isHighlight: true),
                                SizedBox(height: 14.h),
                                Center(
                                  child: Text(
                                    'Arigatou Gozaimasu!\nSushimoo POS • Thank You for Dining',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontFamily: 'Courier', fontSize: 11.sp, color: AppColors.inkMuted, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Obx(() => AppButton(
                                label: 'CETAK STRUK FISIK (PRINTER)',
                                icon: Icons.print_outlined,
                                primary: false,
                                loading: controller.loading.value,
                                onPressed: controller.reprint,
                              )),
                          SizedBox(height: 12.h),
                          AppButton(
                            label: 'SELESAI',
                            icon: Icons.check,
                            onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isMonospace = false, bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isHighlight ? AppColors.salmonDark : AppColors.inkMuted,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: isMonospace ? 'Courier' : null,
              fontSize: 13.sp,
              fontWeight: isHighlight || isMonospace ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.emerald : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        32,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : AppColors.hairline,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

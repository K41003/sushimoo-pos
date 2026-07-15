import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/receipt_controller.dart';

class ReceiptPage extends GetView<ReceiptController> {
  const ReceiptPage({super.key});

  String _money(num v) => 'Rp ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = controller.transaction;
    final pay = controller.payment;

    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        title: const Text('Receipt View'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.marginTablet.w,
            vertical: 16.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 440.w),
            child: Column(
              children: [
                // Thermal Receipt Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.hairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Success Stamp Accent
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(100.r),
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

                        // Restaurant Header Stamp
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
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.inkMuted,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Grand Indonesia Mall, Lt. 3 • Jakarta',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppColors.inkFaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Custom Dashed Divider (Simulating thermal print tear line)
                        _buildDashedDivider(),
                        SizedBox(height: 16.h),

                        // Transaction Metadata (Receipt Style)
                        _buildReceiptRow('Invoice', trx.invoiceNumber, isMonospace: true),
                        _buildReceiptRow('Tanggal', trx.tanggal.substring(0, trx.tanggal.length > 16 ? 16 : trx.tanggal.length)),
                        _buildReceiptRow('Table / Layanan', trx.table?.nomorMeja != null ? 'Meja ${trx.table!.nomorMeja}' : 'Takeaway'),
                        SizedBox(height: 8.h),

                        _buildDashedDivider(),
                        SizedBox(height: 16.h),

                        // Item List Header
                        Text(
                          'ITEMS ORDERED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // Ordered Items
                        ...?trx.details?.map(
                          (d) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${d.qty}x ',
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: AppColors.ink,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    d.product?.namaProduk ?? 'Item #${d.idProduk}',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 14.sp,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  _money(d.subtotal),
                                  style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 14.sp,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),

                        _buildDashedDivider(),
                        SizedBox(height: 16.h),

                        // Total Calculation Breakdown
                        _buildReceiptRow('Subtotal', _money(controller.subtotal), isMonospace: true),
                        _buildReceiptRow('Pajak (10%)', _money(controller.tax), isMonospace: true),
                        SizedBox(height: 6.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL BILL:',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              _money(trx.total),
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.salmonDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        _buildDashedDivider(),
                        SizedBox(height: 16.h),

                        // Payment info
                        _buildReceiptRow('Metode Bayar', pay.method?.namaMetode ?? pay.status.toUpperCase()),
                        _buildReceiptRow('Uang Diterima', _money(pay.uangDiterima), isMonospace: true),
                        _buildReceiptRow('Uang Kembalian', _money(pay.kembalian), isMonospace: true, isHighlight: true),
                        SizedBox(height: 14.h),

                        // Thermal Footer Slogan
                        Center(
                          child: Text(
                            'Arigatou Gozaimasu!\nSushimoo POS • Thank You for Dining',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11.sp,
                              color: AppColors.inkMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Manual print thermal receipt button
                Obx(() => AppButton(
                      label: 'CETAK STRUK FISIK (PRINTER)',
                      icon: Icons.print_outlined,
                      primary: false,
                      loading: controller.loading.value,
                      onPressed: controller.reprint,
                    )),
                SizedBox(height: 12.h),

                // Done button back to main app
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
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isMonospace = false,
    bool isHighlight = false,
  }) {
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

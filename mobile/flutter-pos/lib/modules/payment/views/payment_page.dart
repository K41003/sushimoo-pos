import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/payment_controller.dart';

/// REPLACES `payment_page.dart` 1:1 — same class name `PaymentPage`,
/// same `GetView<PaymentController>`.
class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = controller.transaction;

    return AppScaffold(
      title: 'Payment Confirmation',
      currentRoute: AppRoutes.payment,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520.w),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.marginTablet.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.salmonSoft.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                      border: Border.all(color: AppColors.salmonBorder),
                    ),
                    child: Text(
                      '寿司 SUSHIMOO',
                      style: TextStyle(
                        color: AppColors.salmonDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Invoice Overview Card
                GlassPanel(
                  radius: AppDimensions.radiusLg,
                  child: Column(
                    children: [
                      Text(
                        'INVOICE DETAIL',
                        style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        trx.invoiceNumber,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 12.h),
                      const Divider(),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Table / Layanan', style: theme.textTheme.bodyMedium),
                          Text(
                            trx.table?.nomorMeja != null
                                ? 'Meja ${trx.table!.nomorMeja}'
                                : 'Takeaway (Bawa Pulang)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tanggal', style: theme.textTheme.bodyMedium),
                          Text(
                            trx.tanggal.substring(0, trx.tanggal.length > 10 ? 10 : trx.tanggal.length),
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment section
                GlassPanel(
                  radius: AppDimensions.radiusLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('METODE BAYAR', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.5)),
                      SizedBox(height: 12.h),
                      Obx(() {
                        final selectedId = controller.selectedMethod.value;
                        return Row(
                          children: [
                            _buildMethodButton(
                              context: context,
                              id: 1,
                              name: 'Cash (Tunai)',
                              icon: Icons.payments_outlined,
                              isSelected: selectedId == 1,
                              onTap: () {
                                controller.selectedMethod.value = 1;
                                controller.receivedController.clear();
                              },
                            ),
                            SizedBox(width: 8.w),
                            _buildMethodButton(
                              context: context,
                              id: 2,
                              name: 'QRIS Scan',
                              icon: Icons.qr_code_scanner_outlined,
                              isSelected: selectedId == 2,
                              onTap: () => controller.selectedMethod.value = 2,
                            ),
                            SizedBox(width: 8.w),
                            _buildMethodButton(
                              context: context,
                              id: 3,
                              name: 'Kartu Debit',
                              icon: Icons.credit_card_outlined,
                              isSelected: selectedId == 3,
                              onTap: () => controller.selectedMethod.value = 3,
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20.h),

                      // Bill overview box
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                          border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Tagihan:',
                                    style: TextStyle(fontFamily: 'Courier', fontSize: 14.sp, color: AppColors.inkMuted)),
                                Text(
                                  'Rp ${trx.total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontFamily: 'Courier', fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColors.ink),
                                ),
                              ],
                            ),
                            Obx(() {
                              if (!controller.isCash || controller.receivedText.value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final receivedAmt = double.tryParse(controller.receivedText.value) ?? 0;
                              final changeAmt = controller.change;
                              final hasShortfall = receivedAmt < trx.total;

                              return Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Column(
                                  children: [
                                    const Divider(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          hasShortfall ? 'Kurang Bayar:' : 'Kembalian:',
                                          style: TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: 14.sp,
                                            color: hasShortfall ? AppColors.danger : AppColors.emerald,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          hasShortfall
                                              ? 'Rp ${(trx.total - receivedAmt).toStringAsFixed(0)}'
                                              : 'Rp ${changeAmt.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: hasShortfall ? AppColors.danger : AppColors.emerald,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),

                      Obx(() {
                        if (!controller.isCash) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('UANG TUNAI DITERIMA', style: theme.textTheme.labelSmall),
                            SizedBox(height: 6.h),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                                border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
                              ),
                              child: TextField(
                                controller: controller.receivedController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontFamily: 'Courier', fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.ink),
                                decoration: InputDecoration(
                                  prefixText: 'Rp ',
                                  prefixStyle: TextStyle(fontFamily: 'Courier', fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.inkMuted),
                                  hintText: 'Contoh: 100000',
                                  hintStyle: TextStyle(fontFamily: 'Courier', fontSize: 16.sp, color: AppColors.inkFaint),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                Obx(() {
                  final isCash = controller.isCash;
                  final received = double.tryParse(controller.receivedText.value) ?? 0;
                  final isButtonDisabled = isCash && (controller.receivedText.value.isEmpty || received < trx.total);

                  return AppButton(
                    label: 'SELESAIKAN ORDER / BAYAR',
                    loading: controller.loading.value,
                    onPressed: isButtonDisabled ? null : controller.pay,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodButton({
    required BuildContext context,
    required int id,
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.salmonGradient : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.glassBorder(opacity: 0.7),
              width: 1.2,
            ),
            boxShadow: isSelected ? AppColors.shadowSalmon : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20.sp, color: isSelected ? Colors.white : AppColors.inkMuted),
              SizedBox(height: 6.h),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/payment_controller.dart';

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
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.marginTablet.w,
              vertical: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal Japanese Accent Header
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.salmonSoft,
                      borderRadius: BorderRadius.circular(4.r),
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
                AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(18.r),
                    child: Column(
                      children: [
                        Text(
                          'INVOICE DETAIL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          trx.invoiceNumber,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.extrabold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        const Divider(),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Table / Layanan', style: theme.textTheme.bodyMedium),
                            Text(
                              trx.table?.nomorMeja != null ? 'Meja ${trx.table!.nomorMeja}' : 'Takeaway (Bawa Pulang)',
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Payment Section Card
                AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(18.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'METODE BAYAR',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.5,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Premium Custom Selectable Payment Methods
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
                                onTap: () {
                                  controller.selectedMethod.value = 2;
                                },
                              ),
                              SizedBox(width: 8.w),
                              _buildMethodButton(
                                context: context,
                                id: 3,
                                name: 'Kartu Debit',
                                icon: Icons.credit_card_outlined,
                                isSelected: selectedId == 3,
                                onTap: () {
                                  controller.selectedMethod.value = 3;
                                },
                              ),
                            ],
                          );
                        }),
                        SizedBox(height: 20.h),

                        // Bill Overview Box (Monospace Minimalist)
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Tagihan:',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 14.sp,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${trx.total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink,
                                    ),
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
                                  padding: EdgeInsets.top(8.h),
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
                                              color: hasShortfall ? AppColors.danger : Colors.emerald,
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
                                              color: hasShortfall ? AppColors.danger : Colors.emerald,
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

                        // Cash Input Field (Only visible when cash is selected)
                        Obx(() {
                          if (!controller.isCash) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UANG TUNAI DITERIMA',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              TextField(
                                controller: controller.receivedController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                                decoration: InputDecoration(
                                  prefixText: 'Rp ',
                                  prefixStyle: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.inkMuted,
                                  ),
                                  hintText: 'Contoh: 100000',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 16.sp,
                                    color: AppColors.inkFaint,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Bayar Button
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
      child: Material(
        color: isSelected ? AppColors.salmonSoft : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
              border: Border.all(
                color: isSelected ? AppColors.salmon : AppColors.hairline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? AppColors.salmonDark : AppColors.inkMuted,
                ),
                SizedBox(height: 6.h),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.salmonDark : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

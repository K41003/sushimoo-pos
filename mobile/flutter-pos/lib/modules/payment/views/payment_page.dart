import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/payment_controller.dart';
import '../widgets/screen_shield_wrapper.dart';

/// REPLACES `payment_page.dart` 1:1 — same class name `PaymentPage`,
/// same `GetView<PaymentController>`.
///
/// SECURITY FIX (audit finding #10): this page renders cash-received and
/// change-due amounts — sensitive financial data — but was NOT wrapped
/// in [ScreenShieldWrapper], even though that widget already existed in
/// the codebase (`screen_shield_wrapper.dart`) and is used to disable
/// screenshots/screen recording (Android FLAG_SECURE equivalent) and
/// obscure the view in the app switcher. It is now applied here, so the
/// existing security control actually takes effect on the page it was
/// built for.
///
/// =====================================================================
/// UX FIX (design review P0 #1): Payment previously had NO way back to
/// POS if a cashier noticed the wrong item after reaching this screen —
/// no back arrow, no cancel affordance, only "complete payment" or
/// navigating away through the drawer (which doesn't restore cart
/// state). This is a real operational dead-end on the floor.
///
/// IMPORTANT — what "back" actually means here: by the time this screen
/// is shown, `PosController.placeOrder()` has already POSTed the
/// transaction to the backend and cleared the local cart (see
/// pos_controller.dart). Going back does NOT cancel or undo the placed
/// order — it can't, from this screen alone, without a dedicated
/// cancel/void-transaction API call this app doesn't currently expose.
/// So the back button here is honestly presented as "go back to POS
/// now, deal with the already-placed order later" (e.g. via a manager
/// void/refund flow elsewhere), NOT as "undo this order" — a confirm
/// dialog makes that distinction explicit rather than letting the
/// cashier assume tapping back cancels the sale.
class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  Future<void> _confirmBack(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      title: 'Leave Payment?',
      message: 'This order has already been placed and is NOT cancelled '
          'by going back. If items are wrong, use Void Order from a '
          'manager account after leaving this screen.',
      confirmText: 'Leave',
      cancelText: 'Stay',
    );
    if (confirmed == true) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShieldWrapper(
      child: _PaymentPageBody(onBack: _confirmBack),
    );
  }
}

class _PaymentPageBody extends GetView<PaymentController> {
  final Future<void> Function(BuildContext context) onBack;
  const _PaymentPageBody({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = controller.transaction;

    return AppScaffold(
      title: 'Payment Confirmation',
      currentRoute: AppRoutes.payment,
      showBackButton: true,
      onBackPressed: () => onBack(context),
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

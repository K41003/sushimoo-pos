import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../controllers/receipt_controller.dart';

class ReceiptPage extends GetView<ReceiptController> {
  const ReceiptPage({super.key});

  String _money(num v) => 'Rp ${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trx = controller.transaction;
    final pay = controller.payment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.marginTablet.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 440.w),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle,
                                  color: scheme.primary, size: 48.sp),
                              SizedBox(height: 8.h),
                              Text('Payment Successful',
                                  style:
                                      Theme.of(context).textTheme.headlineMedium),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: 12.h),
                        _kv(context, 'Invoice', trx.invoiceNumber),
                        _kv(context, 'Table', trx.table?.nomorMeja ?? '-'),
                        _kv(context, 'Date', trx.tanggal),
                        SizedBox(height: 12.h),
                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: 12.h),
                        Text('Items',
                            style: Theme.of(context).textTheme.labelLarge),
                        SizedBox(height: 8.h),
                        ...?trx.details?.map(
                          (d) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${d.qty}x ${d.product?.namaProduk ?? 'Item #${d.idProduk}'}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(_money(d.subtotal)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: 12.h),
                        _kv(context, 'Subtotal', _money(controller.subtotal)),
                        _kv(context, 'Tax', _money(controller.tax)),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Total',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            Text(
                              _money(trx.total),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: scheme.primary),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: 12.h),
                        _kv(context, 'Payment Method',
                            pay.method?.namaMetode ?? '-'),
                        _kv(context, 'Received', _money(pay.uangDiterima)),
                        _kv(context, 'Change', _money(pay.kembalian)),
                        _kv(context, 'Status', pay.status.toUpperCase()),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(() => AppButton(
                      label: 'Print Receipt',
                      icon: Icons.print_outlined,
                      primary: false,
                      loading: controller.loading.value,
                      onPressed: controller.reprint,
                    )),
                SizedBox(height: 12.h),
                AppButton(
                  label: 'Done',
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

  Widget _kv(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

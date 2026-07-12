import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
    return AppScaffold(
      title: 'Payment',
      currentRoute: AppRoutes.payment,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480.w),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.marginTablet.w),
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    children: [
                      Text('Invoice: ${controller.transaction.invoiceNumber}'),
                      SizedBox(height: 8.h),
                      Text('Table: ${controller.transaction.table?.nomorMeja ?? '-'}'),
                      SizedBox(height: 8.h),
                      Text('Total: Rp ${controller.transaction.total.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Method',
                          style: Theme.of(context).textTheme.labelLarge),
                      SizedBox(height: 8.h),
                      Obx(() => Wrap(
                            spacing: 8.w,
                            children: controller.methods
                                .map((m) => ChoiceChip(
                                      label: Text(m['name'] as String),
                                      selected:
                                          controller.selectedMethod.value == m['id'],
                                      onSelected: (_) =>
                                          controller.selectedMethod.value = m['id'] as int,
                                    ))
                                .toList(),
                          )),
                      SizedBox(height: 12.h),
                      Obx(() => controller.isCash
                          ? AppTextField(
                              label: 'Received Amount',
                              controller: controller.receivedController,
                              keyboardType: TextInputType.number,
                            )
                          : const SizedBox.shrink()),
                      SizedBox(height: 8.h),
                      Obx(() => controller.isCash
                          ? Text('Change: Rp ${controller.change.toStringAsFixed(0)}')
                          : const SizedBox.shrink()),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(() => AppButton(
                      label: 'Pay Now',
                      loading: controller.loading.value,
                      onPressed: controller.pay,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

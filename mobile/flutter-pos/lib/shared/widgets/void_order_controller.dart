import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import '../../app/services/api_client.dart';
import '../../app/services/local_data_service.dart';
import '../../data/models/transaction.dart';
import 'admin_pin_dialog.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'glass_panel.dart';

class VoidOrderController {
  static Future<bool> attemptVoid(BuildContext context, Transaction trx) async {
    if (trx.status.toLowerCase() == 'paid') {
      EasyLoading.showError('Cannot void an order that has already been paid.');
      return false;
    }

    final reason = await _promptReason();
    if (reason == null || reason.trim().isEmpty) return false;

    final approved = await AdminPinDialog.show(
      title: 'Admin Approval Required',
      message: 'Voiding order ${trx.invoiceNumber} requires admin approval.',
    );
    if (!approved) {
      EasyLoading.showInfo('Void cancelled — admin approval required.');
      return false;
    }

    EasyLoading.show(status: 'Voiding order...');
    if (AppConstants.localMode) {
      await LocalDataService.to.updateTransactionStatus(
        trx.idTransaksi,
        'void',
        reason: reason.trim(),
      );
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Order ${trx.invoiceNumber} voided');
      return true;
    }
    final res = await ApiClient.to.post(
      '/transaksi/${trx.idTransaksi}/void',
      body: {'alasan': reason.trim()},
    );
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess('Order ${trx.invoiceNumber} voided');
      return true;
    } else {
      EasyLoading.showError(res.message);
      return false;
    }
  }

  static Future<String?> _promptReason() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Get.dialog<String>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: GlassPanel(
            radius: AppDimensions.radiusXl,
            strong: true,
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text('Void Order', style: Theme.of(Get.context!).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Please state the reason for voiding this order. Admin approval will be required next.',
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppTextField(
                    label: 'Reason',
                    controller: controller,
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Cancel',
                          primary: false,
                          onPressed: () => Get.back(result: null),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Continue',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Get.back(result: controller.text);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

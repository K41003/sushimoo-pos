import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import '../../app/constants/strings.dart';
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
      EasyLoading.showError('Order yang sudah dibayar tidak bisa dibatalkan.');
      return false;
    }

    final reason = await _promptReason();
    if (reason == null || reason.trim().isEmpty) return false;

    final approved = await AdminPinDialog.show(
      title: 'Persetujuan Admin Diperlukan',
      message: 'Membatalkan order ${trx.invoiceNumber} memerlukan persetujuan admin.',
    );
    if (!approved) {
      EasyLoading.showInfo('Pembatalan dibatalkan — persetujuan admin diperlukan.');
      return false;
    }

    EasyLoading.show(status: 'Membatalkan order...');
    if (AppConstants.localMode) {
      await LocalDataService.to.updateTransactionStatus(
        trx.idTransaksi,
        'void',
        reason: reason.trim(),
      );
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Order ${trx.invoiceNumber} dibatalkan');
      return true;
    }
    final res = await ApiClient.to.post(
      '/transaksi/${trx.idTransaksi}/void',
      body: {'alasan': reason.trim()},
    );
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess('Order ${trx.invoiceNumber} dibatalkan');
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
                  Text('Batalkan Order', style: Theme.of(Get.context!).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Sebutkan alasan pembatalan order ini. Persetujuan admin akan diminta selanjutnya.',
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  AppTextField(
                    label: 'Alasan',
                    controller: controller,
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.required : null,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: AppStrings.cancel,
                          primary: false,
                          onPressed: () => Get.back(result: null),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Lanjutkan',
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

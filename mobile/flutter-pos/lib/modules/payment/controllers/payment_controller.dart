import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/payment.dart';

class PaymentController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final Transaction transaction;
  final methods = const [
    {'id': 1, 'name': 'Cash'},
    {'id': 2, 'name': 'QRIS'},
    {'id': 3, 'name': 'Debit'},
  ];

  final selectedMethod = Rxn<int>();
  final receivedController = TextEditingController();
  final loading = false.obs;

  PaymentController({required this.transaction});

  double get change {
    final received = double.tryParse(receivedController.text) ?? 0;
    return (received - transaction.total).clamp(0, double.infinity);
  }

  bool get isCash => selectedMethod.value == 1;

  Future<void> pay() async {
    if (selectedMethod.value == null) {
      EasyLoading.showError('Select payment method');
      return;
    }
    final body = <String, dynamic>{'id_metode': selectedMethod.value};
    if (isCash) {
      final received = double.tryParse(receivedController.text) ?? 0;
      if (received < transaction.total) {
        EasyLoading.showError('Insufficient amount');
        return;
      }
      body['uang_diterima'] = received;
    }

    loading.value = true;
    EasyLoading.show(status: 'Paying...');
    final res = await _api.post(
      '/transaksi/${transaction.idTransaksi}/pembayaran',
      body: body,
      fromData: (d) => Payment.fromJson(d as Map<String, dynamic>),
    );
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      await PrinterService.to.printCustomerReceipt(transaction);
      EasyLoading.showSuccess('Payment success');
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

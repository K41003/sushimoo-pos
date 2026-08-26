import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
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

  /// Mirrors [receivedController].text as an observable.
  ///
  /// BUG FIX: `Obx(() => ... controller.change ...)` in payment_page.dart
  /// only rebuilds when an `.obs` value is *read* inside its builder.
  /// A plain `TextEditingController` is NOT observable by GetX, so typing
  /// into the "Received Amount" field never triggered a rebuild and the
  /// "Change" label stayed frozen at its very first computed value
  /// (Rp 0, before anything was typed). Listening to the controller and
  /// mirroring its text into this Rx makes `change` reactive again.
  final receivedText = ''.obs;

  PaymentController({required this.transaction});

  @override
  void onInit() {
    super.onInit();
    receivedController.addListener(() {
      receivedText.value = receivedController.text;
    });
  }

  @override
  void onClose() {
    receivedController.dispose();
    super.onClose();
  }

  double get change {
    final received = double.tryParse(receivedText.value) ?? 0;
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

    if (res.success && res.data != null) {
      EasyLoading.showSuccess('Payment success');
      // Show the receipt/bill screen with full order + payment details
      // instead of jumping straight back to the dashboard. Printing the
      // physical receipt now happens from that screen (with a manual
      // "Print Receipt" button), not automatically here.
      Get.offAndToNamed(
        AppRoutes.receipt,
        arguments: {
          'transaction': transaction,
          'payment': res.data as Payment,
        },
      );
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

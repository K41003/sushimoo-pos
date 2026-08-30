import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/payment.dart';

class PaymentController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final LocalDataService _local = LocalDataService.to;
  final Transaction transaction;
  final methods = const [
    {'id': 1, 'name': 'Cash'},
    {'id': 2, 'name': 'QRIS'},
    {'id': 3, 'name': 'Debit'},
  ];

  final selectedMethod = Rxn<int>();
  final receivedController = TextEditingController();
  final loading = false.obs;

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
    if (AppConstants.localMode) {
      final received = isCash ? (double.tryParse(receivedController.text) ?? 0) : transaction.total;
      final kembalian = isCash ? (received - transaction.total).clamp(0, double.infinity).toDouble() : 0.0;
      final payment = await _local.payTransaction(
        transactionId: transaction.idTransaksi,
        methodId: selectedMethod.value!,
        totalBayar: transaction.total,
        uangDiterima: received,
        kembalian: kembalian,
      );
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Payment success');
      final paidTransaction = Transaction(
        idTransaksi: transaction.idTransaksi,
        invoiceNumber: transaction.invoiceNumber,
        idShift: transaction.idShift,
        idUser: transaction.idUser,
        idMeja: transaction.idMeja,
        tanggal: transaction.tanggal,
        total: transaction.total,
        status: 'paid',
        details: transaction.details,
        table: transaction.table,
        user: transaction.user,
        payment: payment,
      );
      Get.offAndToNamed(
        AppRoutes.receipt,
        arguments: {
          'transaction': paidTransaction,
          'payment': payment,
        },
      );
      return;
    }
    final res = await _api.post(
      '/transaksi/${transaction.idTransaksi}/pembayaran',
      body: body,
      fromData: (d) => Payment.fromJson(d as Map<String, dynamic>),
    );
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success && res.data != null) {
      EasyLoading.showSuccess('Payment success');
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

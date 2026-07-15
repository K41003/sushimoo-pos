import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/payment.dart';

class ReceiptController extends GetxController {
  final Transaction transaction;
  final Payment payment;
  final loading = false.obs;

  ReceiptController({required this.transaction, required this.payment});

  double get subtotal =>
      transaction.details?.fold<double>(0, (sum, d) => sum + d.subtotal) ??
      transaction.total;

  double get tax => (transaction.total - subtotal).clamp(0, double.infinity);

  Future<void> reprint() async {
    loading.value = true;
    EasyLoading.show(status: 'Printing...');
    await PrinterService.to.printCustomerReceipt(transaction);
    loading.value = false;
    EasyLoading.dismiss();
  }
}

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/print_queue_service.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/payment.dart';

/// PRINT QUEUE (this pass): `reprint()` now goes through
/// `PrintQueueService.printCustomerReceipt()` instead of calling
/// `PrinterService` directly. Behavior on the happy path (printer
/// connected) is identical; the difference only shows up when the
/// printer is unreachable — instead of the receipt silently not
/// printing, it auto-retries a few times and then queues for later/
/// manual retry (see print_queue_service.dart, shared/widgets/print_queue_button.dart).
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
    EasyLoading.show(status: 'Mencetak...');
    await PrintQueueService.to.printCustomerReceipt(transaction);
    loading.value = false;
    EasyLoading.dismiss();
  }
}

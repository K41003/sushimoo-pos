import 'package:get/get.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/payment.dart';
import '../controllers/receipt_controller.dart';

class ReceiptBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final transaction = args['transaction'] as Transaction;
    final payment = args['payment'] as Payment;
    Get.lazyPut<ReceiptController>(
      () => ReceiptController(transaction: transaction, payment: payment),
    );
  }
}

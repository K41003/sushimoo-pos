import 'package:get/get.dart';
import '../../../data/models/transaction.dart';
import '../controllers/payment_controller.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    final transaction = Get.arguments as Transaction;
    Get.lazyPut<PaymentController>(() => PaymentController(transaction: transaction));
  }
}

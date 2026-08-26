import 'package:get/get.dart';
import '../controllers/closing_controller.dart';

class ClosingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClosingController>(() => ClosingController());
  }
}

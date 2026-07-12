import 'package:get/get.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/printer_service.dart';
import '../services/storage_service.dart';

/// Registers singleton services used across every module.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(PrinterService(), permanent: true);
  }
}

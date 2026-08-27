import 'package:get/get.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/local_data_service.dart';
import '../services/offline_queue_service.dart';
import '../services/print_queue_service.dart';
import '../services/printer_service.dart';
import '../services/storage_service.dart';
import '../services/secure_storage_service.dart';
import '../services/device_integrity_service.dart';
import '../services/sync_service.dart';

/// Registers singleton services used across every module.
///
/// CATATAN: `SecureStorageService` dan `DeviceIntegrityService` sudah
/// di-`Get.put(..., permanent: true)` lebih awal di `main.dart` (sebelum
/// `runApp`), karena `SplashController` butuh keduanya sedini mungkin.
/// Di sini kita hanya pastikan tidak register dua kali.
///
/// `StorageService` (GetStorage plaintext) TETAP dipertahankan untuk hal
/// non-sensitif yang memang sudah dipakai di banyak tempat (keyTheme,
/// keyShift — bukan kredensial), supaya migrasi ini tidak mengubah
/// seluruh basis kode sekaligus. Token & user WAJIB lewat
/// SecureStorageService saja mulai sekarang — lihat auth_service.dart.
///
/// OFFLINE QUEUE (this pass): `OfflineQueueService` (sqflite-backed
/// queue for orders placed without connectivity) and `SyncService`
/// (drains that queue against `/transaksi`) are registered here as
/// permanent singletons, same lifecycle as every other cross-app
/// service. `OfflineQueueService` must exist before `PosController`
/// can be used (it's read directly in `PosController.placeOrder()`),
/// and `SyncService` must exist before `SplashController` runs its
/// post-login auto-sync — both are safe to construct eagerly here
/// since neither does any network/db I/O until first called.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService(), permanent: true);

    if (!Get.isRegistered<SecureStorageService>()) {
      Get.put(SecureStorageService(), permanent: true);
    }
    if (!Get.isRegistered<DeviceIntegrityService>()) {
      Get.put(DeviceIntegrityService(), permanent: true);
    }

    Get.put(ApiClient(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(LocalDataService(), permanent: true);
    Get.put(PrinterService(), permanent: true);

    Get.put(OfflineQueueService(), permanent: true);
    Get.put(PrintQueueService(), permanent: true);
    Get.put(SyncService(), permanent: true);
  }
}

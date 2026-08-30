import 'package:get/get.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/database_helper.dart';
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
/// LOCAL DATABASE (this pass): `DatabaseHelper` (single SQLite database
/// covering every module — categories, products, ingredients, stock,
/// tables, shifts, transactions, payments, expenses, closing reports)
/// is registered first since `LocalDataService` (and therefore most
/// controllers, which now run fully offline via
/// `AppConstants.localMode`) depend on it. `ApiClient` and the
/// offline-queue/sync services are kept registered — and their source
/// files untouched — purely so the app can be switched back to the
/// Laravel backend later (`--dart-define=LOCAL_MODE=false`) without
/// any binding changes; they simply sit unused while `localMode` is
/// true.
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

    Get.put(DatabaseHelper(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(LocalDataService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(PrinterService(), permanent: true);

    Get.put(OfflineQueueService(), permanent: true);
    Get.put(PrintQueueService(), permanent: true);
    Get.put(SyncService(), permanent: true);
  }
}

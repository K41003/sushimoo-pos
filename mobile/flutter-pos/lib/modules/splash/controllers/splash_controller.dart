import 'package:get/get.dart';
import 'package:sushimoo_pos/app/routes/app_routes.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/device_integrity_service.dart';
import 'package:sushimoo_pos/app/services/secure_storage_service.dart';
import 'package:sushimoo_pos/app/services/sync_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      _runSecurityGateThenCheckSession();
    });
  }

  /// SECURITY GATE (OWASP MASVS-RESILIENCE): dijalankan SEBELUM apapun
  /// lain, termasuk sebelum mengecek sesi login. Jika device tidak
  /// aman (root/jailbreak/emulator di production), user tidak pernah
  /// sampai ke layar login sama sekali — token juga sudah di-wipe oleh
  /// DeviceIntegrityService.
  Future<void> _runSecurityGateThenCheckSession() async {
    final result = await DeviceIntegrityService.to.check();

    if (!result.isSafe && DeviceIntegrityService.hardBlock) {
      Get.offAllNamed(
        AppRoutes.securityBlocked,
        arguments: DeviceIntegrityService.to.messageFor(result.issue),
      );
      return;
    }

    await _checkSession();
  }

  Future<void> _checkSession() async {
    if (!SecureStorageService.to.isLoggedIn) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      final me = await AuthService.to.me().timeout(const Duration(seconds: 6));
      if (me.success) {
        Get.offAllNamed(AppRoutes.dashboard);
        _autoSyncOfflineQueue();
        return;
      }
    } catch (_) {
      await SecureStorageService.to.clearSession();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    await SecureStorageService.to.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }

  /// OFFLINE QUEUE (this pass): opportunistically drains any orders that
  /// were queued locally (see `PosController.placeOrder()` /
  /// `OfflineQueueService`) while the app was offline or backgrounded.
  ///
  /// Fire-and-forget on purpose — navigation to the dashboard already
  /// happened above, so the cashier isn't blocked waiting on this. If
  /// there's still no connection, `SyncService.syncNow()` is a safe
  /// no-op (see sync_service.dart). `showToast: false` is used here so
  /// a routine background sync doesn't pop an EasyLoading toast over
  /// the dashboard the instant it renders; the "Sync Now" button
  /// (shared/widgets/sync_status_button.dart) still reflects live
  /// pending-count via `OfflineQueueService.pendingCount`, and a manual
  /// tap always shows its own toast.
  void _autoSyncOfflineQueue() {
    SyncService.to.syncNow(showToast: false);
  }
}

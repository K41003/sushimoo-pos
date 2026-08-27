import 'package:get/get.dart';
import 'package:sushimoo_pos/app/routes/app_routes.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/device_integrity_service.dart';
import 'package:sushimoo_pos/app/services/secure_storage_service.dart';
import 'package:sushimoo_pos/app/services/sync_service.dart';
import 'package:sushimoo_pos/app/constants/app_constants.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      _runSecurityGateThenCheckSession();
    });
  }

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

    if (AppConstants.localMode) {
      Get.offAllNamed(AppRoutes.dashboard);
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

  void _autoSyncOfflineQueue() {
    SyncService.to.syncNow(showToast: false);
  }
}

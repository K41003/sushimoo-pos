import 'package:get/get.dart';
import 'package:sushimoo_pos/app/routes/app_routes.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/device_integrity_service.dart';
import 'package:sushimoo_pos/app/services/secure_storage_service.dart';

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
}

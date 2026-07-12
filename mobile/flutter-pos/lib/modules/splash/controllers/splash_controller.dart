import 'package:get/get.dart';
import 'package:sushimoo_pos/app/routes/app_routes.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Beri jeda agar widget selesai di-render sepenuhnya oleh Flutter sebelum pindah rute
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    print("=== CEK SESSION DIMULAI ===");
    if (!StorageService.to.isLoggedIn) {
      print("=== USER BELUM LOGIN, PINDAH KE LOGIN ===");
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      print("=== MENCOBA MENGHUBUNGI API LARAVEL... ===");
      final me = await AuthService.to.me().timeout(const Duration(seconds: 6));

      print("=== API MERESPONS, SUCCESS: ${me.success} ===");
      if (me.success) {
        Get.offAllNamed(AppRoutes.dashboard);
        return;
      }
    } catch (e) {
      print("=== API EROR/TIMEOUT DETECTED: $e ===");
      await StorageService.to.clearSession();
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    print("=== FALLBACK RUNNING ===");
    await StorageService.to.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}

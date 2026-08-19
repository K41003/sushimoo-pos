import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/initial_binding.dart';
import 'app/constants/app_constants.dart';
import 'app/constants/colors.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/device_integrity_service.dart';
import 'app/services/secure_storage_service.dart';
import 'app/themes/theme.dart';
import 'app/config/scroll_behavior.dart';

// PERUBAHAN KEAMANAN PENTING:
// `import 'dart:io'` dan class `MyHttpOverrides` DIHAPUS SELURUHNYA.
//
// Versi lama file ini berisi:
//   HttpOverrides.global = MyHttpOverrides();
//   ...
//   class MyHttpOverrides extends HttpOverrides {
//     HttpClient createHttpClient(SecurityContext? context) {
//       return super.createHttpClient(context)
//         ..badCertificateCallback = (cert, host, port) => true;
//     }
//   }
//
// Ini MENERIMA SERTIFIKAT TLS APAPUN secara global untuk SELURUH app,
// termasuk sertifikat self-signed milik penyerang MITM. Ini adalah
// kerentanan OWASP MASVS-NETWORK-1 tingkat kritis. Validasi sertifikat
// sekarang ditangani per-request oleh `SslPinningInterceptor` di
// `api_client.dart`, dengan default sistem TLS Dart yang benar (tidak
// dioverride) sebagai baseline, ditambah pinning di atasnya.
//
// Jika sebelumnya override ini dipasang karena error semacam
// "CERTIFICATE_VERIFY_FAILED" di emulator dev, itu tandanya
// `AppConstants.baseUrl` dev perlu pakai HTTP biasa (10.0.2.2, non-TLS)
// bukan mematikan validasi TLS secara global.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(AppConstants.boxName);

  // SecureStorageService menggantikan StorageService sebagai sumber
  // token/session. Didaftarkan permanent SEBELUM runApp supaya splash
  // bisa langsung membaca token yang sudah terenkripsi.
  Get.put(SecureStorageService(), permanent: true);
  Get.put(DeviceIntegrityService(), permanent: true);

  runApp(const MyApp());
  _configureLoading();
}

void _configureLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..indicatorColor = AppColors.salmon
    ..progressColor = AppColors.salmon
    ..backgroundColor = Colors.white
    ..textColor = AppColors.ink
    ..maskColor = AppColors.ink.withValues(alpha: 0.15)
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..maskType = EasyLoadingMaskType.black
    ..radius = 14;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => GetMaterialApp(
        title: 'SUSHIMOO POS',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        getPages: AppPages.pages,
        initialBinding: InitialBinding(),
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        scrollBehavior: const AppScrollBehavior(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

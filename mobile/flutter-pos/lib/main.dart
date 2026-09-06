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

// PERUBAHAN KEAMANAN PENTING (existing, unchanged):
// `import 'dart:io'` dan class `MyHttpOverrides` DIHAPUS SELURUHNYA —
// see original comment history. Sertifikat TLS validation ditangani oleh
// `SslPinningInterceptor`, default sistem TLS Dart tetap aktif.
//
// SECURITY FIX ADDED (audit finding #5): `AppConstants
// .assertSecureBaseUrlInRelease()` now runs before `runApp`, so a
// release build configured (accidentally or otherwise) with a
// non-HTTPS `API_BASE_URL` refuses to start instead of silently
// sending POS/payment traffic in plaintext.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fail fast: refuse to launch a release build pointed at a non-HTTPS
  // API endpoint. No-op in debug/profile.
  AppConstants.assertSecureBaseUrlInRelease();

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

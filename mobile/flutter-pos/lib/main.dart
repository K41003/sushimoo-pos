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
import 'app/services/storage_service.dart';
import 'app/themes/theme.dart';
import 'app/config/scroll_behavior.dart';
import 'dart:io';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(AppConstants.boxName);

  Get.put(StorageService());

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
        // Single "Minimalis Putih" theme — no dark mode branching, so
        // contrast and the salmon accent stay consistent.
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        scrollBehavior: const AppScrollBehavior(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

// Tambahkan class ini di bagian paling bawah file main.dart (di luar fungsi main)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

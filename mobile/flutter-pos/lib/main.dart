import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  // ORIENTATION LOCK (this pass): phones run portrait-only, tablets run
  // landscape-only — there is no "rotate and see a different layout"
  // mode anymore. This removes an entire class of layout bugs (the
  // tablet-portrait tier from the previous pass, and the mid-rotation
  // states in between) by making the device's *shortest side* the only
  // thing that decides orientation, checked once here before the first
  // frame, rather than trying to keep every screen looking right across
  // every possible orientation.
  //
  // `PlatformDispatcher.instance.views.first.physicalSize` gives the raw
  // screen size before any Flutter widget (and therefore before
  // `MediaQuery`) exists yet, which is what we need this early. Divided
  // by `devicePixelRatio` to get logical pixels for the 600dp tablet
  // threshold (matching `Responsive.tabletBreakpoint`).
  final view = ui.PlatformDispatcher.instance.views.first;
  final physicalSize = view.physicalSize;
  final logicalShortestSide =
      (physicalSize.shortestSide) / view.devicePixelRatio;
  final isTabletDevice = logicalShortestSide >= 600;

  await SystemChrome.setPreferredOrientations(
    isTabletDevice
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp],
  );

  // SecureStorageService menggantikan StorageService sebagai sumber
  // token/session. Didaftarkan permanent SEBELUM runApp supaya splash
  // bisa langsung membaca token yang sudah terenkripsi.
  Get.put(SecureStorageService(), permanent: true);
  Get.put(DeviceIntegrityService(), permanent: true);

  runApp(MyApp(isTabletDevice: isTabletDevice));
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
  final bool isTabletDevice;
  const MyApp({super.key, required this.isTabletDevice});

  @override
  Widget build(BuildContext context) {
    // Two fixed reference sizes instead of one compromise size — this
    // is the actual fix for the "still broken on phone" issue: the
    // previous single `Size(1280, 800)` design size was tuned for
    // landscape tablets, so every `.w`/`.h`/`.sp` value in the app was
    // scaled down by a portrait phone's width÷1280 ratio, which is a
    // completely different aspect ratio than what those numbers were
    // designed against. Now that orientation itself is locked per
    // device (see main()), each device class gets a design size that
    // actually matches the orientation it will only ever run in:
    //   - phones:  390×844  (portrait, iPhone-12-ish reference — a
    //     reasonable modern-phone midpoint)
    //   - tablets: 1280×800 (landscape, this app's primary/reference
    //     layout, unchanged from before)
    final designSize = isTabletDevice
        ? const Size(1280, 800)
        : const Size(390, 844);

    return ScreenUtilInit(
      designSize: designSize,
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
        // Aplikasi ini hanya mendukung Bahasa Indonesia — tidak ada
        // pemilih bahasa dan tidak ada fallback ke Inggris. `locale`
        // dikunci ke id_ID dan `supportedLocales` hanya berisi satu
        // entri, sehingga widget bawaan Flutter/Material (mis. teks
        // default pada beberapa komponen sistem) juga konsisten
        // berbahasa Indonesia, bukan hanya teks yang kita tulis sendiri.
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: EasyLoading.init(),
      ),
    );
  }
}

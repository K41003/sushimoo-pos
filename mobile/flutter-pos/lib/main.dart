import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'shared/utils/responsive.dart';

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
//
// RESPONSIVE FIX (this pass): `ScreenUtilInit.designSize` used to be
// hardcoded to `Size(1280, 800)` — a tablet-landscape reference size —
// applied unconditionally to every device, including phones. Every
// `.r`/`.h`/`.w`/`.sp` value in the app (icon sizes, spacing, font
// sizes) is computed as a ratio against `designSize`, so on a ~360-430
// logical-pixel-wide phone screen every one of those values came out
// far smaller than intended: content rendered tiny and clumped near the
// top of the screen instead of filling/centering properly, which is
// exactly the "big empty space at the bottom" seen on the login page
// (and, since every screen uses the same scaling, everywhere else too).
//
// `shared/utils/responsive.dart`'s own doc comment claims the app locks
// orientation per device at startup ("phones are portrait-only, tablets
// are landscape-only... see main.dart"). A previous pass here noted
// that claim was never actually implemented and left it that way,
// treating the mismatch as out of scope — but that gap turned out to
// cause a real, severe bug: a tablet launching in its natural portrait
// orientation combined with `designSize` unconditionally assuming
// landscape (`_tabletDesignSize` below) made every scaled dimension in
// the app come out far too large (giant title text, oversized login
// form, content clipped below the fold). The orientation lock is
// implemented now — see `_lockOrientationForDeviceClass()` below — so
// `shared/utils/responsive.dart`'s doc comment is accurate again.

// ORIENTATION LOCK (this pass): implements what `shared/utils/
// responsive.dart`'s doc comment already claimed happens here — "phones
// are portrait-only, tablets are landscape-only... see main.dart" — but
// never actually did until now. Its absence was silently tolerated for
// a while because most testing happened on phones (which default to
// portrait anyway), but it produces a severe, visible bug on tablets:
// `designSize` below picks `_tabletDesignSize` (1280x800, a LANDSCAPE
// reference) for any device with shortestSide >= 600, assuming that
// device will actually be rendered in landscape. Without a real lock, a
// tablet can launch in portrait — its actual rendered width is much
// smaller than the 1280 the scale ratio assumes, so every `.sp`/`.h`/
// `.w` value in the app comes out far too large (giant "SUSHIMOO" text,
// oversized login form, content clipped below the fold — exactly what
// was reported). Locking orientation makes the two assumptions
// (designSize's aspect ratio, and the device's actual aspect ratio)
// impossible to disagree.
Future<void> _lockOrientationForDeviceClass() async {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalSize = view.physicalSize / view.devicePixelRatio;
  final isTablet = logicalSize.shortestSide >= Responsive.tabletBreakpoint;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp],
  );
}

/// Portrait phone reference size. Matches a common baseline device
/// width/height ratio; `flutter_screenutil` only needs this to compute
/// scale ratios, not to pin an exact device.
const _phoneDesignSize = Size(400, 850);
const _tabletDesignSize = Size(1280, 800);

// BLACK-SCREEN FIX (defensive): previously there was no global error
// handler at all. Any uncaught exception during startup or a widget
// build — including future ones, not just the two fixed in this pass
// (see AppConstants.assertSecureBaseUrlInRelease and
// SslPinningInterceptor) — had no consistent visible failure mode: in
// some cases Flutter's default red/grey error screen shows, but errors
// thrown before the first frame (like both bugs fixed this pass) or
// inside a zone Flutter isn't watching can simply leave the native
// splash/black surface on screen forever with nothing in the visible UI
// to tell you why, especially in a release build on a real device where
// there's no attached debugger. `runZonedGuarded` + `FlutterError.onError`
// + `PlatformDispatcher.instance.onError` make sure every uncaught error
// is at minimum logged, and `FlutterError.onError` additionally routes
// framework build/layout/paint errors through `ErrorWidget.builder` so a
// visible (if minimal) error screen renders instead of nothing.
void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught async error: $error\n$stack');
      return true;
    };

    // The app is fully offline (`AppConstants.localMode`) — text must
    // never depend on a network font fetch. `google_fonts` fetches from
    // fonts.gstatic.com on first use if a font isn't already cached
    // on-device; on a real device's very first launch (no cache yet)
    // with no/flaky internet this can delay or blank text rendering.
    // Disabling runtime fetching makes every `GoogleFonts.*()` call fall
    // back to the platform default font immediately instead, which is
    // the correct behavior for an app that must work with zero network
    // access.
    GoogleFonts.config.allowRuntimeFetching = false;

    // Must run before anything else touches `designSize`/`ScreenUtilInit`
    // (see `MyApp.build()` below) — otherwise there's a window where the
    // device could still be in its natural (unlocked) orientation when
    // the design-size decision is made.
    await _lockOrientationForDeviceClass();

    // Fail fast: refuse to launch a release build pointed at a non-HTTPS
    // API endpoint. No-op in debug/profile, and no-op in `localMode`
    // (see AppConstants.assertSecureBaseUrlInRelease for why).
    AppConstants.assertSecureBaseUrlInRelease();

    await GetStorage.init(AppConstants.boxName);

    // SecureStorageService menggantikan StorageService sebagai sumber
    // token/session. Didaftarkan permanent SEBELUM runApp supaya splash
    // bisa langsung membaca token yang sudah terenkripsi.
    Get.put(SecureStorageService(), permanent: true);
    Get.put(DeviceIntegrityService(), permanent: true);

    runApp(const MyApp());
    _configureLoading();
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
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
    // Read the physical screen size directly from `PlatformDispatcher`
    // rather than `MediaQuery.of(context)`: at this point `MyApp` is the
    // widget passed straight to `runApp`, so there is no guaranteed
    // `MediaQuery` ancestor yet (that's normally provided further down
    // by `WidgetsApp`/`MaterialApp`, which hasn't been built). Reading
    // the platform view directly avoids depending on widget-tree
    // plumbing that may not exist yet at the root.
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    // Same threshold as `Responsive.tabletBreakpoint` (600 logical px
    // shortest side), so `designSize` and every later `Responsive`
    // decision agree on what counts as "tablet".
    final shortestSide = logicalSize.shortestSide;
    final isTablet = shortestSide >= Responsive.tabletBreakpoint;
    final designSize = isTablet ? _tabletDesignSize : _phoneDesignSize;

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      fontSizeResolver: (fontSize, instance) {
        // Clamps font scaling factor between 0.85 and 1.25 so fonts never
        // shrink too small on compact tablets/phones or explode on large screens.
        final scale = instance.scaleText.clamp(0.85, 1.25);
        return fontSize * scale;
      },
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

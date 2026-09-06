import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Widget wrapper yang mengaktifkan screen shielding (mencegah
/// screenshot & screen recording; menyamarkan tampilan di app-switcher)
/// selama widget ini berada di widget tree.
///
/// =====================================================================
/// FIX (correction after real `flutter analyze` run): the previous
/// version of this file imported `package:no_screenshot/no_screenshot.dart`
/// and called `NoScreenshot.instance.screenshotOff()` /
/// `.screenshotOn()`. That package was never actually a dependency of
/// this project — the real `pubspec.yaml` uses `screen_protector: ^1.5.3`
/// instead, which has a different (static-method, not singleton-instance)
/// API. This was a wrong assumption on my part, not a pre-existing gap
/// in your tree — rewritten to match the package you actually have,
/// verified against screen_protector's real API surface:
///   - `ScreenProtector.preventScreenshotOn()` /
///     `.preventScreenshotOff()` — supported on both Android and iOS,
///     blocks screenshots/screen recording while the screen is active.
///   - `ScreenProtector.protectDataLeakageOn()` /
///     `.protectDataLeakageOff()` — Android-only, redacts the app's
///     thumbnail in the recent-apps switcher (no-ops on iOS; iOS instead
///     uses `protectDataLeakageWithColor/Blur/Image`, not needed here
///     since we don't have iOS-specific branding assets for this).
///
/// OWASP MASVS-STORAGE-1 (mencegah kebocoran data sensitif lewat
/// screenshot/recording/app-switcher thumbnail, mis. jumlah kembalian
/// tunai, atau invoice detail).
///
/// USAGE (applied to PaymentPage and ReceiptPage):
/// ```dart
/// return ScreenShieldWrapper(
///   child: AppScaffold(...),
/// );
/// ```
class ScreenShieldWrapper extends StatefulWidget {
  final Widget child;
  const ScreenShieldWrapper({super.key, required this.child});

  @override
  State<ScreenShieldWrapper> createState() => _ScreenShieldWrapperState();
}

class _ScreenShieldWrapperState extends State<ScreenShieldWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableShield();
  }

  Future<void> _enableShield() async {
    try {
      await ScreenProtector.preventScreenshotOn();
      // Android-only; no-ops safely on iOS per package docs.
      await ScreenProtector.protectDataLeakageOn();
    } catch (_) {
      // Non-fatal: beberapa device/OS version bisa menolak; jangan
      // crash alur pembayaran karena ini.
    }
  }

  Future<void> _disableShield() async {
    try {
      await ScreenProtector.preventScreenshotOff();
      await ScreenProtector.protectDataLeakageOff();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Matikan shield saat keluar dari halaman sensitif supaya halaman
    // lain (mis. product gallery) tetap bisa di-screenshot user seperti
    // biasa.
    _disableShield();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-assert shield saat kembali dari background — beberapa OEM
    // Android me-reset flag proteksi saat app resume dari task switcher.
    if (state == AppLifecycleState.resumed) {
      _enableShield();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

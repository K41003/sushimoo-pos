import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:no_screenshot/no_screenshot.dart';

/// Widget wrapper yang mengaktifkan screen shielding (mencegah
/// screenshot & screen recording di Android; menyamarkan tampilan saat
/// app masuk background di iOS) selama widget ini berada di widget tree.
///
/// OWASP MASVS-STORAGE-1 (mencegah kebocoran data sensitif lewat
/// screenshot/recording, mis. nomor kartu, jumlah kembalian tunai, atau
/// invoice detail).
///
/// PEMAKAIAN: bungkus body dari PaymentPage / ReceiptPage:
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
  final _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableShield();
  }

  Future<void> _enableShield() async {
    try {
      await _noScreenshot.screenshotOff();
    } catch (_) {
      // Non-fatal: beberapa device/OS version bisa menolak; jangan
      // crash alur pembayaran karena ini.
    }
  }

  Future<void> _disableShield() async {
    try {
      await _noScreenshot.screenshotOn();
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
    // Android me-reset FLAG_SECURE saat app resume dari task switcher.
    if (state == AppLifecycleState.resumed) {
      _enableShield();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

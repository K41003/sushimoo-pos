import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';

/// Widget wrapper yang mengaktifkan screen shielding (mencegah
/// screenshot & screen recording di Android; menyamarkan tampilan saat
/// app masuk background di iOS) selama widget ini berada di widget tree.
///
/// OWASP MASVS-STORAGE-1 (mencegah kebocoran data sensitif lewat
/// screenshot/recording, mis. nomor kartu, jumlah kembalian tunai, atau
/// invoice detail).
///
/// PAKET DIGANTI (build fix): sebelumnya pakai `no_screenshot ^0.3.6`,
/// yang source Kotlin-nya (`NoScreenshotPlugin.kt`) mendeklarasikan
/// konstanta yang sama baik sebagai top-level property maupun di dalam
/// companion object — bentrok ("Conflicting declarations" / "Overload
/// resolution ambiguity") saat dikompilasi dengan Kotlin/AGP versi baru,
/// sehingga `flutter run` gagal total di step `compileDebugKotlin`. Ini
/// bug di dalam plugin itu sendiri, bukan di kode aplikasi, dan belum
/// ada rilis perbaikan dari upstream-nya per saat ini.
///
/// Diganti ke `screen_protector`, paket yang lebih aktif dipelihara dan
/// menyediakan kapabilitas yang sama (blokir screenshot & screen
/// recording di Android via FLAG_SECURE, plus app-switcher blur di iOS).
/// API publik widget ini (`ScreenShieldWrapper({child})`) TIDAK berubah,
/// jadi tidak ada call site lain yang perlu disentuh.
///
/// WAJIB: tambahkan `screen_protector: ^1.4.2` (atau versi stabil
/// terbaru) ke `pubspec.yaml`, lalu hapus baris `no_screenshot` dari
/// `pubspec.yaml` dan jalankan `flutter pub get`. Paket lama tidak lagi
/// dipakai di mana pun setelah perubahan ini.
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableShield();
  }

  Future<void> _enableShield() async {
    try {
      await ScreenProtector.preventScreenshotOn();
    } catch (_) {
      // Non-fatal: beberapa device/OS version bisa menolak; jangan
      // crash alur pembayaran karena ini.
    }
  }

  Future<void> _disableShield() async {
    try {
      await ScreenProtector.preventScreenshotOff();
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

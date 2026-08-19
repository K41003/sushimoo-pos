import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';
import 'secure_storage_service.dart';

/// Hasil pemeriksaan integritas device, dipakai UI untuk menampilkan
/// pesan yang sesuai tanpa membocorkan detail teknis ke user awam
/// (mis. jangan bilang "Frida hook terdeteksi" ke kasir).
enum IntegrityIssue {
  none,
  rooted,
  jailbroken,
  emulator,
  developerModeOnMoneyScreen, // opsional, tergantung kebijakan bisnis
  mockLocation,
  unknown,
}

class DeviceIntegrityResult {
  final bool isSafe;
  final IntegrityIssue issue;
  const DeviceIntegrityResult(this.isSafe, this.issue);
}

/// OWASP MASVS-RESILIENCE-1 (anti-tampering) & RESILIENCE-4
/// (anti-root/jailbreak). Dijalankan sekali saat splash, DAN
/// idealnya di-recheck sebelum aksi sensitif (mis. sebelum `pay()` di
/// PaymentController) karena root bisa terjadi setelah app sudah jalan
/// (root cloaking / dynamic root toggle).
///
/// KEBIJAKAN: app ini adalah POS yang memegang uang tunai & kredensial
/// kasir. Rekomendasi: BLOK total di device rooted/jailbroken (bukan
/// cuma warning), karena app ini bukan app konten biasa — ada resiko
/// manipulasi total transaksi / bypass validasi pembayaran di device
/// root. Sesuaikan `hardBlock` dengan kebijakan bisnis Anda.
class DeviceIntegrityService extends GetxService {
  static DeviceIntegrityService get to => Get.find<DeviceIntegrityService>();

  final Rx<DeviceIntegrityResult> lastResult =
      Rx<DeviceIntegrityResult>(const DeviceIntegrityResult(true, IntegrityIssue.none));

  /// true = app menolak berjalan sama sekali di device tidak aman.
  /// Set false jika hanya ingin menampilkan warning non-blocking.
  static const bool hardBlock = true;

  Future<DeviceIntegrityResult> check() async {
    try {
      // Di debug/profile mode selama development, safe_device tetap
      // jalan tapi emulator-check akan sering true — jangan hard-block
      // saat kDebugMode supaya development tidak terganggu.
      if (kDebugMode) {
        final result = const DeviceIntegrityResult(true, IntegrityIssue.none);
        lastResult.value = result;
        return result;
      }

      final isJailBroken = await SafeDevice.isJailBroken; // covers root+jailbreak
      if (isJailBroken) {
        final issue = defaultTargetPlatform == TargetPlatform.iOS
            ? IntegrityIssue.jailbroken
            : IntegrityIssue.rooted;
        final result = DeviceIntegrityResult(false, issue);
        lastResult.value = result;
        await _onUnsafeDetected(result);
        return result;
      }

      final isRealDevice = await SafeDevice.isRealDevice;
      if (!isRealDevice) {
        final result = const DeviceIntegrityResult(false, IntegrityIssue.emulator);
        lastResult.value = result;
        await _onUnsafeDetected(result);
        return result;
      }

      final isMockLocation = await SafeDevice.isMockLocation;
      if (isMockLocation) {
        // Untuk POS biasanya tidak fatal (bukan app berbasis lokasi),
        // tapi dicatat — ubah ke hard fail jika bisnis butuh lokasi
        // outlet yang valid untuk absensi/shift.
        final result = const DeviceIntegrityResult(true, IntegrityIssue.mockLocation);
        lastResult.value = result;
        return result;
      }

      final result = const DeviceIntegrityResult(true, IntegrityIssue.none);
      lastResult.value = result;
      return result;
    } catch (e) {
      // Fail-safe policy: jika deteksi sendiri gagal (mis. plugin error
      // di device tertentu), JANGAN otomatis anggap "aman" secara diam2.
      // Tandai unknown supaya UI bisa memilih untuk tetap warn.
      final result = const DeviceIntegrityResult(true, IntegrityIssue.unknown);
      lastResult.value = result;
      return result;
    }
  }

  Future<void> _onUnsafeDetected(DeviceIntegrityResult result) async {
    if (!hardBlock) return;
    // Wipe token dari secure storage supaya device tidak-trusted ini
    // tidak bisa dipakai untuk replay session yang sudah ada.
    try {
      await SecureStorageService.to.panicWipe();
    } catch (_) {
      // service mungkin belum ready saat pertama kali dicek — aman
      // untuk diabaikan, wipe akan tetap terjadi di siklus berikutnya.
    }
  }

  String messageFor(IntegrityIssue issue) {
    switch (issue) {
      case IntegrityIssue.rooted:
        return 'Perangkat ini terdeteksi ROOTED. Untuk keamanan transaksi '
            'dan data pelanggan, aplikasi POS tidak dapat dijalankan di '
            'perangkat yang telah di-root.';
      case IntegrityIssue.jailbroken:
        return 'Perangkat ini terdeteksi JAILBROKEN. Aplikasi tidak dapat '
            'dijalankan pada perangkat yang telah di-jailbreak.';
      case IntegrityIssue.emulator:
        return 'Aplikasi tidak dapat dijalankan pada emulator/simulator.';
      case IntegrityIssue.mockLocation:
        return 'Lokasi palsu (mock location) terdeteksi.';
      case IntegrityIssue.developerModeOnMoneyScreen:
        return 'Mohon nonaktifkan Developer Mode sebelum melanjutkan.';
      case IntegrityIssue.unknown:
      case IntegrityIssue.none:
        return '';
    }
  }
}

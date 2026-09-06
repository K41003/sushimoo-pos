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
/// (anti-root/jailbreak).
///
/// =====================================================================
/// SECURITY FIX (audit finding #4):
/// =====================================================================
/// PREVIOUS VERSION: if the integrity check itself threw (plugin
/// failure, OS quirk, or — relevantly — an attacker on a rooted device
/// deliberately interfering with the native `safe_device` calls, which
/// is EXACTLY the threat model this check exists to catch), the catch
/// block returned `DeviceIntegrityResult(true, IntegrityIssue.unknown)`.
/// That is a fail-OPEN security gate: any exception silently equals
/// "device is safe, let them in." On a POS app that explicitly states
/// rooted devices risk "manipulasi total transaksi / bypass validasi
/// pembayaran", failing open on the exact failure mode an attacker would
/// try to induce is a serious gap.
///
/// FIX: the catch block now returns `isSafe: false` with
/// `IntegrityIssue.unknown`. `hardBlock` policy is applied per-issue via
/// `_shouldHardBlock()` below so that:
///   - Confirmed rooted/jailbroken/emulator -> always hard block
///     (unchanged behavior, still policy-configurable via hardBlock).
///   - `unknown` (plugin genuinely failed, no attacker signal) -> does
///     NOT immediately hard-block by default, to avoid bricking the app
///     for legitimate users on a flaky device/OS combo. Instead it is
///     surfaced to Splash as a soft state the caller can choose to warn
///     on, log, or escalate — but it is never silently treated as safe.
/// This preserves "don't lock out users because a plugin hiccuped" while
/// removing the silent fail-open. The important change: `isSafe` is now
/// always `false` for `unknown`, so any caller checking `result.isSafe`
/// (rather than manually special-casing `unknown`) gets the safe
/// (non-passing) answer by default.
class DeviceIntegrityService extends GetxService {
  static DeviceIntegrityService get to => Get.find<DeviceIntegrityService>();

  final Rx<DeviceIntegrityResult> lastResult =
      Rx<DeviceIntegrityResult>(const DeviceIntegrityResult(true, IntegrityIssue.none));

  /// true = app menolak berjalan sama sekali di device yang terkonfirmasi
  /// tidak aman (rooted/jailbroken/emulator).
  static const bool hardBlock = true;

  /// Separate, more conservative policy for the `unknown` case (the
  /// integrity check itself failed to run). Kept false by default so a
  /// flaky plugin/OS combo doesn't lock out legitimate cashiers, but see
  /// `messageFor` — the UI must still visibly warn, never silently pass.
  static const bool hardBlockOnUnknown = false;

  Future<DeviceIntegrityResult> check() async {
    try {
      if (kDebugMode) {
        const result = DeviceIntegrityResult(true, IntegrityIssue.none);
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
        const result = DeviceIntegrityResult(false, IntegrityIssue.emulator);
        lastResult.value = result;
        await _onUnsafeDetected(result);
        return result;
      }

      final isMockLocation = await SafeDevice.isMockLocation;
      if (isMockLocation) {
        const result = DeviceIntegrityResult(true, IntegrityIssue.mockLocation);
        lastResult.value = result;
        return result;
      }

      const result = DeviceIntegrityResult(true, IntegrityIssue.none);
      lastResult.value = result;
      return result;
    } catch (e) {
      // FAIL-CLOSED (fixed): an exception during the integrity check is
      // no longer treated as "safe". `isSafe` is false; whether that
      // becomes a hard block is governed by `hardBlockOnUnknown`
      // (see class doc), but it is NEVER silently passed through.
      const result = DeviceIntegrityResult(false, IntegrityIssue.unknown);
      lastResult.value = result;
      if (hardBlockOnUnknown) {
        await _onUnsafeDetected(result);
      }
      return result;
    }
  }

  /// Whether a given check result should hard-block navigation past
  /// Splash. Centralizes the two policies (`hardBlock`,
  /// `hardBlockOnUnknown`) so callers don't have to know both flags.
  bool shouldHardBlock(DeviceIntegrityResult result) {
    if (result.isSafe) return false;
    if (result.issue == IntegrityIssue.unknown) return hardBlockOnUnknown;
    return hardBlock;
  }

  Future<void> _onUnsafeDetected(DeviceIntegrityResult result) async {
    if (!shouldHardBlock(result)) return;
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
        return 'Tidak dapat memverifikasi keamanan perangkat ini saat ini. '
            'Silakan coba lagi, atau hubungi admin IT jika berlanjut.';
      case IntegrityIssue.none:
        return '';
    }
  }
}

import 'package:flutter/foundation.dart';

/// =====================================================================
/// SECURITY FIX (audit finding #5):
/// =====================================================================
/// PREVIOUS VERSION hardcoded a single constant:
///
///   static const String baseUrl = "http://10.0.2.2/api";
///
/// with no environment/flavor separation anywhere in the app. That
/// value only resolves inside the Android emulator loopback — a
/// release build using it verbatim would be non-functional in
/// production, creating exactly the kind of pressure that leads to an
/// engineer "temporarily" pointing it at a real production host over
/// plain HTTP to unblock a release deadline. There was also no
/// build-time check preventing a release build from shipping with a
/// plaintext `http://` API endpoint.
///
/// FIX: `baseUrl` is now sourced from a build-time `--dart-define`, with
/// the old emulator loopback kept ONLY as the default (so `flutter run`
/// in debug still works with zero config), and a release-mode assertion
/// that refuses to start if the resolved URL is not HTTPS.
///
/// Build examples:
///   Debug (emulator, unchanged default):
///     flutter run
///   Staging:
///     flutter run --dart-define=API_BASE_URL=https://staging-api.sushimoo-pos.com/api
///   Production release:
///     flutter build apk --release \
///       --dart-define=API_BASE_URL=https://api.sushimoo-pos.com/api \
///       --dart-define=PINNED_FINGERPRINT_LEAF=... \
///       --dart-define=PINNED_FINGERPRINT_BACKUP=...
class AppConstants {
  AppConstants._();

  // =====================================================================
  // REGRESSION FIX: `localMode` existed in the real working tree BEFORE
  // this file was overwritten by the audit patch and was accidentally
  // deleted, breaking 11 call sites across auth_service.dart,
  // sync_service.dart, dashboard/expense/ingredient/payment/report/
  // shift/table controllers, and two shared widgets (admin_pin_dialog,
  // void_order_controller).
  //
  // This is not a toggle — it's the app's actual architecture decision:
  // the app runs fully offline against a local sqflite database via
  // `LocalDataService`, and the Laravel `ApiClient` path is either
  // unused or reserved for a future/optional sync layer. Kept `true`
  // and `const` (not environment-overridable) so it can't be silently
  // flipped by a stray --dart-define at build time — if this ever
  // becomes a real per-build toggle, make that change deliberately, not
  // as a side effect of a define name colliding.
  // =====================================================================
  static const bool localMode = true;

  static const String _defaultDevBaseUrl = "http://10.0.2.2/api";

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultDevBaseUrl,
  );

  /// Call once at app startup (see main.dart) to fail fast if a release
  /// build is about to ship with a non-HTTPS API endpoint.
  ///
  /// BLACK-SCREEN FIX: this used to run unconditionally, including when
  /// `localMode` is true. Since `localMode` means the app never talks to
  /// `baseUrl` at all (everything goes through the local sqflite DB via
  /// `LocalDataService`), a plain `flutter build apk --release` /
  /// `flutter run --release` on a real device — with no
  /// `--dart-define=API_BASE_URL=...` supplied, which is the normal case
  /// while `localMode` is the app's actual architecture — hit
  /// `kReleaseMode == true` and `baseUrl == _defaultDevBaseUrl`
  /// ("http://10.0.2.2/api", not https), so this threw a `StateError`
  /// BEFORE `runApp` was ever called in main.dart. No widget tree is ever
  /// built in that case, which is exactly what a permanent black screen
  /// on a real device (but never in `flutter run` debug, where
  /// `kReleaseMode` is false) looks like. Guard it behind `!localMode` so
  /// the check only fires when the app is actually configured to talk to
  /// a real backend over HTTP.
  static void assertSecureBaseUrlInRelease() {
    if (localMode) return;
    if (kReleaseMode && !baseUrl.startsWith('https://')) {
      throw StateError(
          'Release build is configured with a non-HTTPS API_BASE_URL '
          '("$baseUrl"). Rebuild with '
          '--dart-define=API_BASE_URL=https://your-production-host/api');
    }
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Tax rate applied to subtotal for the POS grand total.
  static const double taxRate = 0.0;

  /// Storage keys (GetStorage).
  static const String boxName = 'sushimoo';
  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  static const String keyShift = 'shift';

  /// Payment methods (mirrors metode_pembayaran seed).
  static const List<String> paymentMethods = ['Cash', 'QRIS', 'Debit'];
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

/// OWASP MASVS-NETWORK-1: verifikasi channel komunikasi aman.
///
/// =====================================================================
/// SECURITY FIX (audit finding #1 + #2):
/// =====================================================================
/// PREVIOUS VERSION problems:
///   1. `_pinnedFingerprints` was a `static const` list of literal
///      PLACEHOLDER strings baked into source. The only guard against
///      shipping that was a `throw StateError(...)` INSIDE the request
///      interceptor at runtime — meaning a release build with
///      unfilled fingerprints would compile and pass CI fine, and only
///      fail (loudly, or worse: unpredictably depending on how future
///      code wraps this interceptor in try/catch) the first time a
///      real user opened the app in production.
///   2. `allowInsecureDev = kDebugMode` had no additional guard. If a
///      build was ever produced with `kDebugMode == true` outside of
///      normal `flutter run` (misconfigured CI, a `--debug` release
///      artifact shipped by mistake), pinning silently no-ops.
///   3. `api_client.dart` hardcoded a `Host: laravel-api.test` header
///      on every request regardless of `baseUrl` — a dev-only artifact
///      with no place in a client that might ship to production.
///
/// FIX:
///   - Fingerprints are now injected at BUILD time via
///     `--dart-define=PINNED_FINGERPRINT_LEAF=...` and
///     `--dart-define=PINNED_FINGERPRINT_BACKUP=...`, read via
///     `String.fromEnvironment`. There is NO literal placeholder string
///     that can accidentally ship — if the defines are omitted, the
///     values are simply empty strings, which fail an explicit
///     assertion at construction time (`kReleaseMode` builds refuse to
///     even start), rather than failing lazily on first network call.
///   - `allowInsecureDev` now requires BOTH `kDebugMode` AND
///     `!kReleaseMode` to be true (belt-and-suspenders — kReleaseMode
///     should already imply !kDebugMode, but we don't rely on that
///     invariant holding forever).
///   - The stray `Host` header override has been removed from
///     `api_client.dart` (see that file's patch).
///
/// STRATEGI PIN GANDA: tetap simpan MINIMAL 2 fingerprint (leaf cert +
/// backup/intermediate), agar rotasi sertifikat tidak langsung mem-brick
/// seluruh armada aplikasi yang sudah di-publish.
class SslPinningInterceptor extends Interceptor {
  /// Injected at build time — never hardcode real or placeholder
  /// fingerprints in source. Example release build command:
  ///
  ///   flutter build apk --release \
  ///     --dart-define=PINNED_FINGERPRINT_LEAF=AB:CD:EF:... \
  ///     --dart-define=PINNED_FINGERPRINT_BACKUP=11:22:33:...
  ///
  /// Obtain the fingerprint for your production API host with:
  ///
  ///   openssl s_client -connect api.sushimoo-pos.com:443 \
  ///     -servername api.sushimoo-pos.com </dev/null 2>/dev/null \
  ///     | openssl x509 -noout -fingerprint -sha256
  static const String _leafFingerprint =
      String.fromEnvironment('PINNED_FINGERPRINT_LEAF', defaultValue: '');
  static const String _backupFingerprint =
      String.fromEnvironment('PINNED_FINGERPRINT_BACKUP', defaultValue: '');

  List<String> get _pinnedFingerprints => [
        if (_leafFingerprint.isNotEmpty) _leafFingerprint,
        if (_backupFingerprint.isNotEmpty) _backupFingerprint,
      ];

  /// Saat dev lokal (emulator -> 10.0.2.2, tanpa TLS asli), pinning
  /// dinonaktifkan otomatis supaya tidak menghalangi development.
  ///
  /// Hardened: requires BOTH kDebugMode AND !kReleaseMode so a build
  /// misconfiguration that only flips one flag can't disable pinning.
  final bool allowInsecureDev;

  SslPinningInterceptor({bool? allowInsecureDev})
      : allowInsecureDev = allowInsecureDev ?? (kDebugMode && !kReleaseMode) {
    // Fail FAST at construction (app startup), not lazily on the first
    // network request. A release build that somehow has no fingerprints
    // configured must refuse to run at all rather than silently allow
    // unpinned traffic or throw mid-request.
    if (kReleaseMode && _pinnedFingerprints.length < 2) {
      throw StateError(
          'Release build started without SSL pinning fingerprints. '
          'Build with --dart-define=PINNED_FINGERPRINT_LEAF=... and '
          '--dart-define=PINNED_FINGERPRINT_BACKUP=... . Refusing to '
          'start rather than shipping unpinned network traffic.');
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (allowInsecureDev) {
      return handler.next(options);
    }

    try {
      final secure = await HttpCertificatePinning.check(
        serverURL: options.uri.toString(),
        headerHttp: const {},
        sha: SHA.SHA256,
        allowedSHAFingerprints: _pinnedFingerprints,
        timeout: 15,
      );
      // Plugin mengembalikan status string; "CONNECTION_SECURE" = pin cocok.
      if (secure != 'CONNECTION_SECURE') {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badCertificate,
            error: 'SSL pinning gagal: sertifikat server tidak cocok '
                'dengan fingerprint yang dipercaya. Kemungkinan serangan '
                'Man-in-the-Middle atau proxy tidak sah.',
          ),
          true,
        );
      }
      handler.next(options);
    } on PlatformException catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badCertificate,
          error: 'SSL pinning check error: ${e.message}',
        ),
        true,
      );
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: 'SSL pinning tidak dapat diverifikasi: $e',
        ),
        true,
      );
    }
  }
}

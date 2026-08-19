import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

/// OWASP MASVS-NETWORK-1: verifikasi channel komunikasi aman.
///
/// MASALAH KRITIS DI `main.dart` SAAT INI:
/// ```dart
/// class MyHttpOverrides extends HttpOverrides {
///   @override
///   HttpClient createHttpClient(SecurityContext? context) {
///     return super.createHttpClient(context)
///       ..badCertificateCallback =
///           (X509Certificate cert, String host, int port) => true; // <-- INI
///   }
/// }
/// ```
/// `badCertificateCallback` yang selalu me-return `true` berarti app
/// MENERIMA SERTIFIKAT APAPUN — termasuk sertifikat self-signed milik
/// penyerang. Ini membuat SELURUH trafik API (login, token, data
/// transaksi, pembayaran) rentan Man-in-the-Middle di jaringan publik
/// (mis. WiFi restoran/mall). Ini SAMA SEKALI BUKAN best practice,
/// bahkan untuk dev — gunakan `AppConstants.baseUrl` yang benar per
/// environment (dev/staging/prod), jangan matikan validasi cert.
///
/// PERBAIKAN: interceptor Dio ini melakukan SHA-256 fingerprint pinning
/// terhadap sertifikat server. Ganti `_pinnedFingerprints` dengan SHA-256
/// fingerprint sertifikat backend Laravel Anda yang sebenarnya (lihat
/// instruksi `_howToGetFingerprint` di bawah).
///
/// STRATEGI PIN GANDA: selalu simpan MINIMAL 2 fingerprint (leaf cert +
/// backup/intermediate), agar rotasi sertifikat tidak langsung mem-brick
/// seluruh armada aplikasi yang sudah di-publish.
class SslPinningInterceptor extends Interceptor {
  /// GANTI dengan fingerprint SHA-256 sertifikat production Anda.
  /// Cara mendapatkan (jalankan di mesin lokal terhadap domain API asli,
  /// BUKAN base URL emulator 10.0.2.2 yang cuma untuk dev lokal):
  ///
  ///   openssl s_client -connect api.sushimoo-pos.com:443 -servername api.sushimoo-pos.com </dev/null 2>/dev/null \
  ///     | openssl x509 -noout -fingerprint -sha256
  ///
  /// Hasilnya seperti: SHA256 Fingerprint=AB:CD:EF:...
  /// Masukkan TANPA titik dua, huruf besar, seperti contoh placeholder
  /// di bawah ini.
  static const List<String> _pinnedFingerprints = [
    'PLACEHOLDER_SHA256_FINGERPRINT_LEAF_CERT',
    'PLACEHOLDER_SHA256_FINGERPRINT_BACKUP_OR_INTERMEDIATE',
  ];

  /// Saat dev lokal (emulator -> 10.0.2.2, tanpa TLS asli), pinning
  /// dinonaktifkan otomatis supaya tidak menghalangi development.
  /// PASTIKAN ini tidak pernah true di build release/production.
  final bool allowInsecureDev;

  SslPinningInterceptor({this.allowInsecureDev = kDebugMode});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (allowInsecureDev) {
      return handler.next(options);
    }

    if (_pinnedFingerprints.any((f) => f.startsWith('PLACEHOLDER'))) {
      // Safety net: jangan biarkan build release lolos dengan
      // fingerprint placeholder yang belum diisi — itu setara tanpa
      // pinning sama sekali tapi terlihat seperti sudah aman.
      throw StateError(
          'SSL pinning fingerprints belum diisi. Isi _pinnedFingerprints '
          'di ssl_pinning_interceptor.dart sebelum build release.');
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


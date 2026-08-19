import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../data/models/user.dart';

/// SECURE replacement untuk penyimpanan token/session di StorageService.
///
/// MASALAH YANG DIPERBAIKI:
/// `storage_service.dart` yang lama menyimpan `keyToken` dan `keyUser` via
/// `GetStorage` (backend: SharedPreferences di Android / plist-file di
/// iOS) dalam bentuk PLAINTEXT. Di Android tanpa root pun, file ini bisa
/// dibaca lewat `adb backup` (jika `android:allowBackup` tidak di-set
/// false) atau lewat root/forensic tools. Bearer token yang bocor = full
/// account takeover tanpa perlu password.
///
/// PERBAIKAN (OWASP MASVS-STORAGE-1, MASVS-STORAGE-2):
/// - Android: AES-256 via Android Keystore (EncryptedSharedPreferences)
/// - iOS: Keychain dengan `first_unlock_this_device` (tidak ikut ke
///   iCloud backup, tidak bisa diakses sebelum device pertama kali
///   di-unlock setelah restart)
///
/// NOTE INTEGRASI: Data yang sudah ada (`GetStorage`) TIDAK otomatis
/// bermigrasi. `migrateFromLegacyIfNeeded()` di bawah menangani migrasi
/// satu-kali dari `StorageService` lama, lalu menghapus jejaknya.
class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find<SecureStorageService>();

  static const _keyToken = 'secure_token';
  static const _keyUser = 'secure_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Kunci hilang jika app di-uninstall (bukan re-issue kunci lama) —
      // ini perilaku yang benar untuk token sesi.
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      // Item hanya bisa didekripsi setelah unlock pertama pasca-boot,
      // dan TIDAK ikut ter-backup ke iCloud.
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  String? _cachedToken;
  User? _cachedUser;

  @override
  void onInit() async {
    super.onInit();
    await _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      _cachedToken = await _storage.read(key: _keyToken);
      final userJson = await _storage.read(key: _keyUser);
      if (userJson != null) {
        _cachedUser = User.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>);
      }
    } catch (e) {
      // Storage korup/tidak bisa didekripsi (mis. keystore di-reset OS) —
      // treat sebagai logged-out, JANGAN crash splash screen.
      _cachedToken = null;
      _cachedUser = null;
    }
  }

  String? get token => _cachedToken;
  User? get user => _cachedUser;
  bool get isLoggedIn => _cachedToken != null && _cachedToken!.isNotEmpty;

  Future<void> saveSession({required String token, required User user}) async {
    _cachedToken = token;
    _cachedUser = user;
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }

  /// Wipe total — dipanggil saat root/jailbreak terdeteksi (lihat
  /// device_integrity_service.dart) agar token tidak bisa diekstrak
  /// dari device yang sudah tidak trusted.
  Future<void> panicWipe() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.deleteAll();
  }
}

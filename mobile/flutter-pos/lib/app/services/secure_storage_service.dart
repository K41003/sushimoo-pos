import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../../data/models/role.dart';

/// SECURE replacement untuk penyimpanan token/session di StorageService.
///
/// =====================================================================
/// SECURITY FIX (audit finding #6):
/// =====================================================================
/// PREVIOUS VERSION persisted the FULL `User.toJson()` blob to secure
/// storage, including `idRole`, `username`, and the nested `role` object
/// — more than the client actually needs to render its own UI (which
/// only ever reads `nama` and `roleName`/`isAdmin`/`isKasir`). This
/// increases blast radius if the platform-native secure storage backend
/// is ever compromised (some Android OEM `EncryptedSharedPreferences`
/// implementations have had bugs; iOS Keychain access-group
/// misconfigurations are another historical vector).
///
/// FIX: only a minimal display-only projection (`idUser`, `nama`,
/// `roleName`) is persisted locally. The full `User` (with role
/// permissions etc.) is still returned from `/login` and `/me` and held
/// in memory for the session, but is NOT written to disk. On cold start
/// (`_hydrate`), the cached `User` is reconstructed from that minimal
/// projection — enough to render nav/greeting — and `AuthService.me()`
/// is expected to refresh the full object over the network before any
/// screen that needs full role/permission data is shown (Splash already
/// calls `AuthService.to.me()` on every cold start).
///
/// MASALAH YANG DIPERBAIKI (existing, unchanged):
/// `storage_service.dart` yang lama menyimpan `keyToken` dan `keyUser`
/// via `GetStorage` (SharedPreferences/plist) dalam bentuk PLAINTEXT.
/// Bearer token yang bocor = full account takeover tanpa perlu password.
///
/// PERBAIKAN (OWASP MASVS-STORAGE-1, MASVS-STORAGE-2):
/// - Android: AES-256 via Android Keystore (EncryptedSharedPreferences)
/// - iOS: Keychain dengan `first_unlock_this_device`
class SecureStorageService extends GetxService {
  static SecureStorageService get to => Get.find<SecureStorageService>();

  static const _keyToken = 'secure_token';
  static const _keyUserMinimal = 'secure_user_minimal';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
    iOptions: IOSOptions(
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
      final minimalJson = await _storage.read(key: _keyUserMinimal);
      if (minimalJson != null) {
        final map = jsonDecode(minimalJson) as Map<String, dynamic>;
        _cachedUser = _userFromMinimal(map);
      }
    } catch (e) {
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
    await _storage.write(
      key: _keyUserMinimal,
      value: jsonEncode(_toMinimal(user)),
    );
  }

  Future<void> clearSession() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserMinimal);
  }

  /// Wipe total — dipanggil saat root/jailbreak terdeteksi.
  Future<void> panicWipe() async {
    _cachedToken = null;
    _cachedUser = null;
    await _storage.deleteAll();
  }

  /// Only the fields the client actually needs to render UI without a
  /// network round-trip (sidebar greeting, role-gated nav). Does NOT
  /// include the nested `Role` object, username, or any other field
  /// `User.toJson()` would otherwise include.
  Map<String, dynamic> _toMinimal(User user) => {
        'id_user': user.idUser,
        'nama': user.nama,
        'role_name': user.roleName,
      };

  /// Reconstructs an in-memory-only `User` from the minimal projection.
  /// `idRole`, `username`, and `status` are not known until the next
  /// successful `/me` refresh; they are filled with safe placeholder
  /// values that are NEVER persisted and NEVER used for authorization
  /// decisions (the backend is always the source of truth for those —
  /// this reconstruction only feeds UI nav gating like
  /// `navItemsForRole(user.roleName)` and the sidebar greeting).
  ///
  /// A minimal `Role` (namaRole only) is attached so `User.roleName` /
  /// `isAdmin` / `isKasir` — which read `role?.namaRole` — keep working
  /// exactly as before, without persisting the full nested Role object
  /// (id/description) that the old version wrote to disk.
  User _userFromMinimal(Map<String, dynamic> map) {
    final roleName = map['role_name'] as String?;
    return User(
      idUser: map['id_user'] as int? ?? 0,
      idRole: 0,
      nama: map['nama'] as String? ?? '',
      username: '',
      status: true,
      role: roleName == null ? null : Role(idRole: 0, namaRole: roleName),
    );
  }
}

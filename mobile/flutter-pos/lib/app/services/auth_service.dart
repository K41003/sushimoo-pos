import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../data/models/role.dart';
import '../../data/models/user.dart';
import '../../data/response/api_response.dart';
import 'api_client.dart';
import 'local_data_service.dart';
import 'secure_storage_service.dart';

class AuthSession {
  final String token;
  final User user;
  AuthSession({required this.token, required this.user});
}

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final ApiClient _api = ApiClient.to;
  final LocalDataService _local = LocalDataService.to;

  Future<ApiResponse<AuthSession>> login(
      String username, String password) async {
    if (AppConstants.localMode) {
      final localUser = await _local.login(username, password);
      if (localUser == null) {
        return ApiResponse(
          success: false,
          message: 'Username atau password salah',
        );
      }
      final user = User(
        idUser: localUser.id ?? 0,
        idRole: localUser.role == 'Admin' ? 1 : 2,
        nama: localUser.name,
        username: localUser.username,
        status: true,
        role: Role(idRole: localUser.id ?? 0, namaRole: localUser.role, deskripsi: null),
      );
      final session = AuthSession(token: localUser.token, user: user);
      await SecureStorageService.to.saveSession(
        token: session.token,
        user: session.user,
      );
      return ApiResponse(success: true, message: 'Login berhasil', data: session);
    }

    final res = await _api.post('/login', body: {
      'username': username,
      'password': password,
    }, fromData: (d) {
      final map = d as Map<String, dynamic>;
      return AuthSession(
        token: map['token'] as String,
        user: User.fromJson(map['user'] as Map<String, dynamic>),
      );
    });

    if (res.success && res.data != null) {
      await SecureStorageService.to.saveSession(
        token: res.data!.token,
        user: res.data!.user,
      );
    }
    return res;
  }

  Future<ApiResponse<void>> logout() async {
    final res = await _api.post('/logout');
    await SecureStorageService.to.clearSession();
    return ApiResponse(success: res.success, message: res.message);
  }

  /// Refreshes the cached [User] profile from `/me`.
  ///
  /// Perilaku fix token-kosong dari versi asli TETAP dipertahankan:
  /// hanya menulis ulang sesi jika token yang ada di storage memang
  /// valid (non-null). Jika null, tidak menimpa apapun.
  Future<ApiResponse<User>> me() async {
    final res = await _api.get('/me', fromData: (d) {
      return User.fromJson(d as Map<String, dynamic>);
    });
    if (res.success && res.data != null) {
      final existingToken = SecureStorageService.to.token;
      if (existingToken != null) {
        await SecureStorageService.to.saveSession(
          token: existingToken,
          user: res.data as User,
        );
      }
    }
    return res;
  }

  bool get isLoggedIn => SecureStorageService.to.isLoggedIn;
  User? get currentUser => SecureStorageService.to.user;
}

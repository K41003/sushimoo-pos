import 'package:get/get.dart';
import '../../data/models/user.dart';
import '../../data/response/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthSession {
  final String token;
  final User user;
  AuthSession({required this.token, required this.user});
}

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final ApiClient _api = ApiClient.to;

  Future<ApiResponse<AuthSession>> login(
      String username, String password) async {
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
      await StorageService.to.saveSession(
        token: res.data!.token,
        user: res.data!.user,
      );
    }
    return res;
  }

  Future<ApiResponse<void>> logout() async {
    final res = await _api.post('/logout');
    await StorageService.to.clearSession();
    return ApiResponse(success: res.success, message: res.message);
  }

  /// Refreshes the cached [User] profile from `/me`.
  ///
  /// BUG FIX (2026-08-17): this previously always called
  /// `StorageService.to.saveSession(token: StorageService.to.token ?? '', ...)`.
  /// If `StorageService.to.token` was ever `null` at the moment this ran
  /// (e.g. called before the session was hydrated, or after another code
  /// path cleared it), the `?? ''` fallback silently wrote an EMPTY STRING
  /// over the real token in persistent storage. `/me` never returns a new
  /// token, so this call has no business touching it at all — it should
  /// only refresh the cached `User`. The next app launch would then send
  /// `Authorization: Bearer ` (empty) and get a 401, causing an
  /// intermittent, hard-to-reproduce forced logout on cold start via
  /// `SplashController._checkSession()`.
  ///
  /// Fix: only call `saveSession` (and thus only touch the token field)
  /// when a token actually exists in storage. If it's null, skip the
  /// write entirely rather than persisting a blank token.
  Future<ApiResponse<User>> me() async {
    final res = await _api.get('/me', fromData: (d) {
      return User.fromJson(d as Map<String, dynamic>);
    });
    if (res.success && res.data != null) {
      final existingToken = StorageService.to.token;
      if (existingToken != null) {
        await StorageService.to.saveSession(
          token: existingToken,
          user: res.data as User,
        );
      }
      // If existingToken is null, there is nothing valid to persist a
      // session against — leave storage untouched instead of corrupting
      // it with an empty token string.
    }
    return res;
  }

  bool get isLoggedIn => StorageService.to.isLoggedIn;
  User? get currentUser => StorageService.to.user;
}

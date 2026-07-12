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

  Future<ApiResponse<User>> me() async {
    final res = await _api.get('/me', fromData: (d) {
      return User.fromJson(d as Map<String, dynamic>);
    });
    if (res.success && res.data != null) {
      await StorageService.to.saveSession(
        token: StorageService.to.token ?? '', user: res.data as User);
    }
    return res;
  }

  bool get isLoggedIn => StorageService.to.isLoggedIn;
  User? get currentUser => StorageService.to.user;
}

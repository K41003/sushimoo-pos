import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/constants/app_constants.dart';
import '../../data/models/user.dart';

/// Thin wrapper over GetStorage for auth + preferences persistence.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();
  late final GetStorage _box;

  String? _token;
  User? _user;

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage(AppConstants.boxName);
    _token = _box.read(AppConstants.keyToken);
    final userMap = _box.read(AppConstants.keyUser);
    if (userMap != null) {
      _user = User.fromJson(Map<String, dynamic>.from(userMap));
    }
  }

  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _token != null;

  Future<void> saveSession({required String token, required User user}) async {
    _token = token;
    _user = user;
    await _box.write(AppConstants.keyToken, token);
    await _box.write(AppConstants.keyUser, user.toJson());
  }

  Future<void> clearSession() async {
    _token = null;
    _user = null;
    await _box.remove(AppConstants.keyToken);
    await _box.remove(AppConstants.keyUser);
    await _box.remove(AppConstants.keyShift);
  }

  bool get isDark => _box.read(AppConstants.keyTheme) ?? true;
  Future<void> setDark(bool value) => _box.write(AppConstants.keyTheme, value);

  Future<void> saveShift(int shiftId) =>
      _box.write(AppConstants.keyShift, shiftId);
  int? get shiftId => _box.read(AppConstants.keyShift);
  Future<void> clearShift() => _box.remove(AppConstants.keyShift);
}

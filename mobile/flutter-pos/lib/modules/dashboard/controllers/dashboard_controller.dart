import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/auth_service.dart';

class DashboardController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final loading = true.obs;
  final isAdmin = false.obs;

  final RxMap adminData = RxMap();
  final RxMap cashierData = RxMap();

  @override
  void onInit() {
    super.onInit();
    isAdmin.value = AuthService.to.currentUser?.isAdmin ?? false;
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final path = isAdmin.value ? '/dashboard/admin' : '/dashboard/cashier';
    final res = await _api.get(path, fromData: (d) => d);
    loading.value = false;
    if (res.success && res.data != null) {
      if (isAdmin.value) {
        adminData.value = res.data as Map;
      } else {
        cashierData.value = res.data as Map;
      }
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

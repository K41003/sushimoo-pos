import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/auth_service.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      EasyLoading.showError('Username and password required');
      return;
    }

    loading.value = true;
    EasyLoading.show(status: 'Login...');
    final res = await AuthService.to.login(username, password);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

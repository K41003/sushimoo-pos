import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/printer_service.dart';
import '../../../app/services/storage_service.dart';

class SettingController extends GetxController {
  final isDark = StorageService.to.isDark.obs;
  final printerConnected = PrinterService.to.isConnected;

  Future<void> toggleTheme(bool value) async {
    isDark.value = value;
    await StorageService.to.setDark(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> connectPrinter() async {
    final devices = await PrinterService.to.getDevices();
    if (devices.isEmpty) {
      EasyLoading.showError('No paired bluetooth printer');
      return;
    }
    final picked = await Get.dialog<dynamic>(
      SimpleDialog(
        title: const Text('Select Printer'),
        children: devices
            .map((d) => SimpleDialogOption(
                  onPressed: () => Get.back(result: d),
                  child: Text(d.name ?? d.address ?? '-'),
                ))
            .toList(),
      ),
    );
    if (picked != null) {
      final ok = await PrinterService.to.connect(picked);
      if (ok) {
        EasyLoading.showSuccess('Printer connected');
      } else {
        EasyLoading.showError('Failed to connect');
      }
    }
  }

  Future<void> logout() async {
    await AuthService.to.logout();
    Get.offAllNamed('/login');
  }
}

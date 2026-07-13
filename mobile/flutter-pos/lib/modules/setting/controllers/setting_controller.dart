import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/printer_service.dart';
import '../../../app/services/storage_service.dart';

class SettingController extends GetxController {
  final isDark = StorageService.to.isDark.obs;

  // FIX: dibuat late + di-assign dengan try-catch di onInit, bukan
  // langsung `PrinterService.to.isConnected` sebagai field initializer.
  // Ini mencegah crash kalau plugin blue_thermal_printer gagal
  // berinteraksi dengan native side (mis. permission Bluetooth belum
  // di-grant / belum dideklarasikan di AndroidManifest.xml).
  late final RxBool printerConnected;

  @override
  void onInit() {
    super.onInit();
    try {
      printerConnected = PrinterService.to.isConnected;
    } catch (_) {
      printerConnected = false.obs;
    }
  }

  Future<void> toggleTheme(bool value) async {
    isDark.value = value;
    await StorageService.to.setDark(value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> connectPrinter() async {
    try {
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
        printerConnected.value = ok;
        if (ok) {
          EasyLoading.showSuccess('Printer connected');
        } else {
          EasyLoading.showError('Failed to connect');
        }
      }
    } catch (e) {
      EasyLoading.showError('Bluetooth error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await AuthService.to.logout();
    Get.offAllNamed('/login');
  }
}

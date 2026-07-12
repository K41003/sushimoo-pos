import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_button.dart';

class AppDialog {
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          AppButton(
            label: confirmText,
            primary: true,
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );
  }

  static Future<void> info(String title, String message) {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }
}

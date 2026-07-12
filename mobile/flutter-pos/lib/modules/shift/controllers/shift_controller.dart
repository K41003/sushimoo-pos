import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/storage_service.dart';
import '../../../data/models/shift.dart';

class ShiftController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final activeShift = Rx<Shift?>(null);
  final pettyCashController = TextEditingController();
  final pettyController = TextEditingController();
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadActive();
  }

  @override
  void onClose() {
    pettyCashController.dispose();
    pettyController.dispose();
    super.onClose();
  }

  Future<void> loadActive() async {
    loading.value = true;
    final res = await _api.get('/shifts/active', fromData: (d) {
      return d == null ? null : Shift.fromJson(d as Map<String, dynamic>);
    });
    loading.value = false;
    if (res.success) {
      final data = res.data;
      activeShift.value = data;
      if (data != null) {
        await StorageService.to.saveShift(data.idShift);
      } else {
        await StorageService.to.clearShift();
      }
    }
  }

  Future<void> openShift() async {
    final petty = double.tryParse(pettyCashController.text) ?? 0;
    loading.value = true;
    EasyLoading.show(status: 'Opening...');
    final res = await _api.post('/shifts/open', body: {'petty_cash': petty});
    loading.value = false;
    EasyLoading.dismiss();
    if (res.success) {
      EasyLoading.showSuccess('Shift opened');
      await loadActive();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> addPettyCash() async {
    if (activeShift.value == null) return;
    final nominal = double.tryParse(pettyController.text) ?? 0;
    if (nominal <= 0) {
      EasyLoading.showError('Nominal required');
      return;
    }
    EasyLoading.show(status: 'Saving...');
    final res = await _api.post(
      '/shifts/${activeShift.value!.idShift}/petty-cash',
      body: {'nominal': nominal, 'keterangan': 'Petty cash'},
    );
    EasyLoading.dismiss();
    if (res.success) {
      pettyController.clear();
      EasyLoading.showSuccess('Petty cash recorded');
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> closeShift() async {
    if (activeShift.value == null) return;
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Close Shift',
      middleText: 'Are you sure you want to close this shift?',
      textConfirm: 'Close',
      textCancel: 'Cancel',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Closing...');
    final res = await _api.post(
      '/shifts/${activeShift.value!.idShift}/close',
    );
    EasyLoading.dismiss();
    if (res.success) {
      EasyLoading.showSuccess('Shift closed');
      await loadActive();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

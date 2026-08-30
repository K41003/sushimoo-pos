import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/local_data_service.dart';
import '../../../app/services/storage_service.dart';
import '../../../data/models/shift.dart';
import '../../../shared/widgets/app_dialog.dart';

class ShiftController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final LocalDataService _local = LocalDataService.to;
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
    if (AppConstants.localMode) {
      final userId = AuthService.to.currentUser?.idUser;
      final shift = userId == null ? null : await _local.getActiveShift(userId);
      activeShift.value = shift;
      if (shift != null) {
        await StorageService.to.saveShift(shift.idShift);
      } else {
        await StorageService.to.clearShift();
      }
      loading.value = false;
      return;
    }
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
    if (AppConstants.localMode) {
      final userId = AuthService.to.currentUser?.idUser;
      if (userId == null) {
        loading.value = false;
        EasyLoading.dismiss();
        EasyLoading.showError('No logged-in user');
        return;
      }
      await _local.openShift(userId: userId, pettyCash: petty);
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Shift opened');
      await loadActive();
      return;
    }
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
    if (AppConstants.localMode) {
      await _local.addPettyCash(activeShift.value!.idShift, nominal);
      EasyLoading.dismiss();
      pettyController.clear();
      EasyLoading.showSuccess('Petty cash recorded');
      await loadActive();
      return;
    }
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
    final confirmed = await AppDialog.confirm(
      title: 'Close Shift',
      message: 'Are you sure you want to close this shift?',
      confirmText: 'Close',
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Closing...');
    if (AppConstants.localMode) {
      await _local.closeShift(activeShift.value!.idShift);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Shift closed');
      await loadActive();
      return;
    }
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

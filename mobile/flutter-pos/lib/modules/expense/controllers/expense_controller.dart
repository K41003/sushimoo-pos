import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/storage_service.dart';
import '../../../data/models/expense.dart';
import '../../../data/response/api_response.dart';

class ExpenseController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final items = <Expense>[].obs;
  final loading = false.obs;

  final kategoriController = TextEditingController();
  final nominalController = TextEditingController();
  final keteranganController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    kategoriController.dispose();
    nominalController.dispose();
    keteranganController.dispose();
    super.onClose();
  }

  int? get shiftId => StorageService.to.shiftId;

  Future<void> load() async {
    loading.value = true;
    final res = await _api.get('/pengeluaran',
        query: {'id_shift': shiftId ?? 0, 'perPage': 100}, fromData: (d) => d);
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Expense>.fromJson({'data': res.data}, Expense.fromJson);
      items.assignAll(pag.items);
    } else if (!res.success) {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> save() async {
    final kategori = kategoriController.text.trim();
    final nominal = double.tryParse(nominalController.text) ?? 0;
    if (kategori.isEmpty || nominal <= 0) {
      EasyLoading.showError('Kategori and nominal required');
      return;
    }
    EasyLoading.show(status: 'Saving...');
    final res = await _api.post('/pengeluaran', body: {
      'kategori': kategori,
      'nominal': nominal,
      'keterangan': keteranganController.text.trim(),
      'tanggal': DateTime.now().toIso8601String(),
    });
    EasyLoading.dismiss();
    if (res.success) {
      kategoriController.clear();
      nominalController.clear();
      keteranganController.clear();
      Get.back();
      EasyLoading.showSuccess('Expense recorded');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Delete Expense',
      middleText: 'Are you sure?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed != true) return;
    EasyLoading.show(status: 'Deleting...');
    final res = await _api.delete('/pengeluaran/$id');
    EasyLoading.dismiss();
    if (res.success) {
      EasyLoading.showSuccess('Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

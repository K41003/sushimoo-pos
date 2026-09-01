import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/strings.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../app/services/storage_service.dart';
import '../../../data/models/expense.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';

class ExpenseController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final LocalDataService _local = LocalDataService.to;
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
    if (AppConstants.localMode) {
      items.value = await _local.getExpenses(shiftId: shiftId);
      loading.value = false;
      return;
    }
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
      EasyLoading.showError('Kategori dan nominal wajib diisi');
      return;
    }
    EasyLoading.show(status: AppStrings.saving);
    if (AppConstants.localMode) {
      final currentShiftId = shiftId;
      if (currentShiftId == null) {
        EasyLoading.dismiss();
        EasyLoading.showError('Tidak ada shift aktif. Buka shift terlebih dahulu.');
        return;
      }
      await _local.addExpense(
        shiftId: currentShiftId,
        kategori: kategori,
        nominal: nominal,
        keterangan: keteranganController.text.trim(),
      );
      kategoriController.clear();
      nominalController.clear();
      keteranganController.clear();
      Get.back();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Pengeluaran tercatat');
      await load();
      return;
    }
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
      EasyLoading.showSuccess('Pengeluaran tercatat');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirmed = await AppDialog.confirm(
      title: AppStrings.confirmDeleteTitle,
      message: 'Apakah kamu yakin ingin menghapus catatan pengeluaran ini?',
      confirmText: AppStrings.delete,
      destructive: true,
    );
    if (confirmed != true) return;
    EasyLoading.show(status: AppStrings.deleting);
    if (AppConstants.localMode) {
      await _local.deleteExpense(id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.deleted);
      await load();
      return;
    }
    final res = await _api.delete('/pengeluaran/$id');
    EasyLoading.dismiss();
    if (res.success) {
      EasyLoading.showSuccess(AppStrings.deleted);
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

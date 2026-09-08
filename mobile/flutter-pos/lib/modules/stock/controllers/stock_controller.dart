import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/decorations.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/stock.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/utils/debouncer.dart';

/// OFFLINE FIX: previously called `ApiClient` unconditionally, ignoring
/// `AppConstants.localMode`. Wired to `LocalDataService`, same pattern
/// as the other CRUD controllers. `getAppStock(search: ...)` and
/// `getAppIngredients()` already support what the API paths needed, so
/// no client-side emulation is required here.
class StockController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final LocalDataService _local = LocalDataService.to;
  final items = <Stock>[].obs;
  final ingredients = <Ingredient>[].obs;
  final loading = false.obs;
  final RxString search = ''.obs;

  // SECURITY FIX (audit finding #8): debounce search-triggered API calls
  // instead of firing one request per keystroke.
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void onInit() {
    super.onInit();
    loadIngredients();
    load();
  }

  @override
  void onClose() {
    _searchDebouncer.dispose();
    super.onClose();
  }

  Future<void> loadIngredients() async {
    if (AppConstants.localMode) {
      ingredients.value = await _local.getAppIngredients();
      return;
    }
    final res = await _api.get(
      '/bahan-baku',
      query: {'perPage': 100},
      fromData: (d) => d,
    );
    if (res.success && res.data != null) {
      final pag = Paginated<Ingredient>.fromJson(
        {'data': res.data},
        Ingredient.fromJson,
      );
      ingredients.value = pag.items;
    }
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      items.value = await _local.getAppStock(search: search.value);
      loading.value = false;
      return;
    }
    final res = await _api.get(
      '/stok-bahan',
      query: {'q': search.value, 'perPage': 50},
      fromData: (d) => d,
    );
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Stock>.fromJson(
        {'data': res.data},
        Stock.fromJson,
      );
      items.value = pag.items;
    } else {
      EasyLoading.showError(res.message);
    }
  }

  void setSearch(String value) {
    search.value = value;
    if (value.trim().isEmpty) {
      _searchDebouncer.dispose();
      load();
      return;
    }
    _searchDebouncer.run(load);
  }

  Future<void> addAdjustment() async {
    if (ingredients.isEmpty) await loadIngredients();
    final selected = Rxn<Ingredient>();
    final jumlah = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await AppDialog.form<bool>(
      title: 'Add Stock Adjustment',
      icon: Icons.inventory_2_rounded,
      maxWidth: 440.w,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ingredient',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted,
              ),
            ),
            SizedBox(height: 6.h),
            Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: AppDecorations.control(radius: AppDimensions.radiusMd),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Ingredient>(
                      isExpanded: true,
                      value: selected.value,
                      hint: Text('Select ingredient',
                          style: TextStyle(color: AppColors.inkFaint, fontSize: 13.5.sp)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.inkMuted),
                      items: ingredients
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  '${e.namaBahan} (${e.satuan})',
                                  style: TextStyle(fontSize: 13.5.sp, color: AppColors.ink),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) => selected.value = v,
                    ),
                  ),
                )),
            SizedBox(height: 14.h),
            AppTextField(
              label: 'Jumlah',
              controller: jumlah,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
      onConfirm: () async {
        if (selected.value == null) {
          EasyLoading.showError('Please select an ingredient');
          return false;
        }
        if (!formKey.currentState!.validate()) return false;
        return true;
      },
    );
    if (result != true || selected.value == null) return;

    loading.value = true;
    EasyLoading.show(status: 'Saving...');
    if (AppConstants.localMode) {
      await _local.addStockAdjustment(
        ingredientId: selected.value!.idBahan,
        jumlah: double.tryParse(jumlah.text) ?? 0,
      );
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved');
      await load();
      return;
    }
    final res = await _api.post(
      '/stok-bahan',
      body: {
        'id_bahan': selected.value!.idBahan,
        'jumlah': double.tryParse(jumlah.text) ?? 0,
      },
      fromData: (d) => d,
    );
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(
          res.message.isNotEmpty ? res.message : 'Saved');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> adjust(Stock stock) async {
    final jumlah =
        TextEditingController(text: stock.jumlah.toString());
    final formKey = GlobalKey<FormState>();

    final result = await AppDialog.form<bool>(
      title: 'Update Stock (${stock.ingredient?.namaBahan ?? 'Item'})',
      icon: Icons.edit_note_rounded,
      maxWidth: 400.w,
      confirmText: 'Update',
      content: Form(
        key: formKey,
        child: AppTextField(
          label: 'Jumlah (${stock.ingredient?.satuan ?? ''})',
          controller: jumlah,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Required' : null,
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return false;
        return true;
      },
    );
    if (result != true) return;

    await updateStock(stock.idStok, double.tryParse(jumlah.text) ?? 0);
  }

  Future<void> updateStock(int id, double jumlah) async {
    loading.value = true;
    EasyLoading.show(status: 'Updating...');
    if (AppConstants.localMode) {
      await _local.updateStock(id, jumlah);
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Updated');
      await load();
      return;
    }
    final res = await _api.put(
      '/stok-bahan/$id',
      body: {'jumlah': jumlah},
      fromData: (d) => d,
    );
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(
          res.message.isNotEmpty ? res.message : 'Updated');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirm = await AppDialog.confirm(
      title: 'Delete Stock',
      message: 'Are you sure you want to delete this stock entry?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: 'Deleting...');
    if (AppConstants.localMode) {
      await _local.deleteStock(id);
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Deleted');
      await load();
      return;
    }
    final res = await _api.delete('/stok-bahan/$id', fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(
          res.message.isNotEmpty ? res.message : 'Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

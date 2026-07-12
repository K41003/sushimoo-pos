import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/models/stock.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';

class StockController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final items = <Stock>[].obs;
  final ingredients = <Ingredient>[].obs;
  final loading = false.obs;
  final RxString search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadIngredients();
    load();
  }

  Future<void> loadIngredients() async {
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
    load();
  }

  Future<void> addAdjustment() async {
    if (ingredients.isEmpty) await loadIngredients();
    final selected = Rxn<Ingredient>();
    final jumlah = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Add Stock Adjustment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => InputDecorator(
                    decoration: const InputDecoration(labelText: 'Ingredient'),
                    child: DropdownButton<Ingredient>(
                      isExpanded: true,
                      value: selected.value,
                      hint: const Text('Select ingredient'),
                      items: ingredients
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.namaBahan),
                              ))
                          .toList(),
                      onChanged: (v) => selected.value = v,
                    ),
                  )),
              SizedBox(height: 12.h),
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
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Add',
            onPressed: () {
              if (formKey.currentState!.validate()) Get.back(result: true);
            },
          ),
        ],
      ),
    );
    if (result != true || selected.value == null) return;

    loading.value = true;
    EasyLoading.show(status: 'Saving...');
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

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Update Stock'),
        content: Form(
          key: formKey,
          child: AppTextField(
            label: 'Jumlah',
            controller: jumlah,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Update',
            onPressed: () {
              if (formKey.currentState!.validate()) Get.back(result: true);
            },
          ),
        ],
      ),
    );
    if (result != true) return;

    await updateStock(stock.idStok, double.tryParse(jumlah.text) ?? 0);
  }

  Future<void> updateStock(int id, double jumlah) async {
    loading.value = true;
    EasyLoading.show(status: 'Updating...');
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
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: 'Deleting...');
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

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';

class IngredientController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final items = <Ingredient>[].obs;
  final loading = false.obs;
  final RxString search = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final res = await _api.get(
      '/bahan-baku',
      query: {'q': search.value, 'perPage': 50},
      fromData: (d) => d,
    );
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Ingredient>.fromJson(
        {'data': res.data},
        Ingredient.fromJson,
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

  Future<void> save(Ingredient? existing) async {
    final nama = TextEditingController(text: existing?.namaBahan ?? '');
    final satuan = TextEditingController(text: existing?.satuan ?? '');
    final minimal = TextEditingController(
      text: existing != null ? existing.minimalStok.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'Add Ingredient' : 'Edit Ingredient'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Nama Bahan',
                controller: nama,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'Satuan',
                controller: satuan,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'Minimal Stok',
                controller: minimal,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            label: 'Save',
            onPressed: () {
              if (formKey.currentState!.validate()) Get.back(result: true);
            },
          ),
        ],
      ),
    );
    if (result != true) return;

    final body = {
      'nama_bahan': nama.text.trim(),
      'satuan': satuan.text.trim(),
      'minimal_stok': double.tryParse(minimal.text) ?? 0,
    };

    loading.value = true;
    EasyLoading.show(status: 'Saving...');
    final res = existing == null
        ? await _api.post('/bahan-baku', body: body, fromData: (d) => d)
        : await _api.put('/bahan-baku/${existing.idBahan}',
            body: body, fromData: (d) => d);
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

  Future<void> delete(int id) async {
    final confirm = await AppDialog.confirm(
      title: 'Delete Ingredient',
      message: 'Are you sure you want to delete this ingredient?',
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: 'Deleting...');
    final res = await _api.delete('/bahan-baku/$id', fromData: (d) => d);
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

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../data/models/ingredient.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/utils/debouncer.dart';

class IngredientController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final items = <Ingredient>[].obs;
  final loading = false.obs;
  final RxString search = ''.obs;

  // SECURITY FIX (audit finding #8): debounce search-triggered API calls
  // instead of firing one request per keystroke.
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    _searchDebouncer.dispose();
    super.onClose();
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
    if (value.trim().isEmpty) {
      _searchDebouncer.dispose();
      load();
      return;
    }
    _searchDebouncer.run(load);
  }

  Future<void> save(Ingredient? existing) async {
    final nama = TextEditingController(text: existing?.namaBahan ?? '');
    final satuan = TextEditingController(text: existing?.satuan ?? '');
    final minimal = TextEditingController(
      text: existing != null ? existing.minimalStok.toString() : '',
    );
    final formKey = GlobalKey<FormState>();

    final result = await AppDialog.form<bool>(
      title: existing == null ? 'Add Ingredient' : 'Edit Ingredient',
      icon: Icons.egg_alt_rounded,
      maxWidth: 420.w,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nama Bahan',
              controller: nama,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 14.h),
            AppTextField(
              label: 'Satuan (e.g. gram, ml, pcs)',
              controller: satuan,
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 14.h),
            AppTextField(
              label: 'Minimal Stok',
              controller: minimal,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return false;
        return true;
      },
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
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : 'Saved');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirm = await AppDialog.confirm(
      title: 'Delete Ingredient',
      message: 'Are you sure you want to delete this ingredient?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: 'Deleting...');
    final res = await _api.delete('/bahan-baku/$id', fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : 'Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

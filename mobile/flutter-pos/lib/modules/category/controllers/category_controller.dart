import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/category.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../widgets/category_form.dart';

class CategoryController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final LocalDataService _local = LocalDataService.to;
  final items = <Category>[].obs;
  final loading = false.obs;
  final search = ''.obs;
  final page = 1.obs;
  final perPage = 15.obs;
  final total = 0.obs;
  final lastPage = 1.obs;

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final selectedStatus = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    search.value = value;
    page.value = 1;
    load();
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      final all = await _local.getAppCategories();
      final query = search.value.trim().toLowerCase();
      final filtered = query.isEmpty ? all : all.where((c) => c.namaKategori.toLowerCase().contains(query)).toList();
      items.assignAll(filtered);
      total.value = filtered.length;
      lastPage.value = 1;
      page.value = 1;
      loading.value = false;
      return;
    }
    try {
      final query = <String, dynamic>{
        'perPage': perPage.value,
        if (search.value.isNotEmpty) 'q': search.value,
      };
      final res = await Get.find<ApiClient>()
          .get('/categories', query: query, fromData: (d) => d);
      if (res.success && res.data != null) {
        final pag =
            Paginated<Category>.fromJson({'data': res.data}, Category.fromJson);
        items.assignAll(pag.items);
        total.value = pag.total;
        lastPage.value = pag.lastPage;
        page.value = pag.page;
      } else if (!res.success) {
        EasyLoading.showError(res.message);
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      loading.value = false;
    }
  }

  void openForm(Category? existing) {
    nameController.text = existing?.namaKategori ?? '';
    descController.text = existing?.deskripsi ?? '';
    selectedStatus.value = existing?.status ?? true;

    AppDialog.form(
      title: existing == null ? 'Add Category' : 'Edit Category',
      icon: Icons.category_rounded,
      maxWidth: 440,
      content: CategoryForm(controller: this, existing: existing),
      onConfirm: () async {
        await createOrUpdate(existing);
        return false;
      },
    );
  }

  Future<void> createOrUpdate(Category? existing) async {
    final nama = nameController.text.trim();
    if (nama.isEmpty) {
      EasyLoading.showError('Nama kategori required');
      return;
    }

    EasyLoading.show(status: 'Saving...');
    if (AppConstants.localMode) {
      await _local.saveCategory(
        id: existing?.idKategori,
        name: nama,
        description: descController.text.trim(),
      );
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved');
      await load();
      return;
    }
    final body = {
      'nama_kategori': nama,
      'deskripsi': descController.text.trim(),
      'status': selectedStatus.value ? 1 : 0,
    };
    final res = existing == null
        ? await Get.find<ApiClient>().post('/categories', body: body)
        : await Get.find<ApiClient>()
            .put('/categories/${existing.idKategori}', body: body);
    EasyLoading.dismiss();

    if (res.success) {
      Get.back();
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : 'Saved');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    if (AppConstants.localMode) {
      await _local.deleteCategory(id);
      EasyLoading.showSuccess('Deleted');
      await load();
      return;
    }
    final confirmed = await AppDialog.confirm(
      title: 'Delete Category',
      message: 'Are you sure you want to delete this category?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Deleting...');
    final res = await Get.find<ApiClient>().delete('/categories/$id');
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : 'Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/category.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/utils/debouncer.dart';
import '../widgets/category_form.dart';

/// OFFLINE FIX: this controller previously called `ApiClient` /
/// `Get.find<ApiClient>()` unconditionally, ignoring
/// `AppConstants.localMode` entirely — unlike every other list+form
/// controller in the app (Table, Expense, Shift, Report, Payment,
/// Dashboard), which already branch on `localMode` and fall back to
/// `LocalDataService`. That meant Category management would hang/fail
/// with no Laravel backend reachable, even though the rest of the app
/// runs fully offline. Wired to the same pattern used everywhere else;
/// the online (`ApiClient`) path below each guard is untouched.
///
/// `LocalDataService.getAppCategories()` has no server-side pagination
/// or `q` search param, so `search`/`page`/`perPage`/`total`/`lastPage`
/// are emulated client-side here to keep the existing search box and
/// pagination fields working identically from the UI's point of view.
class CategoryController extends GetxController {
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

  // SECURITY FIX (audit finding #8): debounce search-triggered API calls.
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    _searchDebouncer.dispose();
    super.onClose();
  }

  void onSearchChanged(String value) {
    search.value = value;
    page.value = 1;
    if (value.trim().isEmpty) {
      _searchDebouncer.dispose();
      load();
      return;
    }
    _searchDebouncer.run(load);
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      try {
        final all = await _local.getAppCategories();
        final q = search.value.trim().toLowerCase();
        final filtered = q.isEmpty
            ? all
            : all.where((c) => c.namaKategori.toLowerCase().contains(q)).toList();
        items.assignAll(filtered);
        total.value = filtered.length;
        lastPage.value = 1;
        page.value = 1;
      } catch (e) {
        EasyLoading.showError(e.toString());
      } finally {
        loading.value = false;
      }
      return;
    }
    try {
      final query = <String, dynamic>{
        'perPage': perPage.value,
        if (search.value.isNotEmpty) 'q': search.value,
      };
      final res = await Get.find<ApiClient>().get('/categories',
          query: query, fromData: (d) => d);
      if (res.success && res.data != null) {
        final pag = Paginated<Category>.fromJson(
            {'data': res.data}, Category.fromJson);
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
        return false; // createOrUpdate handles closing dialog on success
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
        status: selectedStatus.value,
      );
      EasyLoading.dismiss();
      Get.back();
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
        : await Get.find<ApiClient>().put('/categories/${existing.idKategori}',
            body: body);
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
    final confirmed = await AppDialog.confirm(
      title: 'Delete Category',
      message: 'Are you sure you want to delete this category?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Deleting...');
    if (AppConstants.localMode) {
      await _local.deleteCategory(id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Deleted');
      await load();
      return;
    }
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

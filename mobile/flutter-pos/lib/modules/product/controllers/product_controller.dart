import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/utils/debouncer.dart';
import '../widgets/product_form.dart';

import '../../../shared/utils/money.dart';

/// REFACTOR: delegates to the shared `formatRupiah` (see
/// shared/utils/money.dart). Kept as a deprecated wrapper so existing
/// call sites (`money(product.harga)`) elsewhere keep compiling
/// unchanged; behavior is identical to before.
@Deprecated('Use formatRupiah from shared/utils/money.dart instead')
String money(dynamic v) => formatRupiah(v);

/// OFFLINE FIX: previously called `ApiClient`/`Get.find<ApiClient>()`
/// unconditionally, ignoring `AppConstants.localMode`. Wired to
/// `LocalDataService`, same pattern as Category/Ingredient/Stock above.
///
/// `LocalDataService.getAppProducts()` returns every product with no
/// server-side `q`/`id_kategori`/pagination support, so search, category
/// filtering, and pagination fields are all emulated client-side here to
/// keep the existing UI (search box, category chips, pagination) working
/// identically to the online path.
class ProductController extends GetxController {
  final LocalDataService _local = LocalDataService.to;
  final items = <Product>[].obs;
  final categories = <Category>[].obs;
  final loading = false.obs;
  final search = ''.obs;
  final page = 1.obs;
  final perPage = 15.obs;
  final total = 0.obs;
  final lastPage = 1.obs;

  final selectedCategoryId = Rx<int?>(null);

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final selectedCategory = Rx<int?>(null);
  final selectedStatus = true.obs;

  // SECURITY FIX (audit finding #8): debounce free-text search only.
  // Category chip taps (`selectCategory`) are a discrete, low-frequency
  // user action (not a keystroke stream), so they intentionally stay
  // undebounced for a responsive tap-to-filter feel.
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    load();
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
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

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    page.value = 1;
    load();
  }

  Future<void> loadCategories() async {
    if (AppConstants.localMode) {
      try {
        categories.assignAll(await _local.getAppCategories());
      } catch (_) {
        // non-fatal: dropdown simply stays empty
      }
      return;
    }
    try {
      final res = await Get.find<ApiClient>().get('/categories',
          query: {'perPage': 100}, fromData: (d) => d);
      if (res.success && res.data != null) {
        final pag = Paginated<Category>.fromJson(
            {'data': res.data}, Category.fromJson);
        categories.assignAll(pag.items);
      }
    } catch (_) {
      // non-fatal: dropdown simply stays empty
    }
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      try {
        var all = await _local.getAppProducts();
        if (selectedCategoryId.value != null) {
          all = all.where((p) => p.idKategori == selectedCategoryId.value).toList();
        }
        final q = search.value.trim().toLowerCase();
        if (q.isNotEmpty) {
          all = all.where((p) => p.namaProduk.toLowerCase().contains(q)).toList();
        }
        items.assignAll(all);
        total.value = all.length;
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
        if (selectedCategoryId.value != null)
          'id_kategori': selectedCategoryId.value,
      };
      final res = await Get.find<ApiClient>().get('/products',
          query: query, fromData: (d) => d);
      if (res.success && res.data != null) {
        final pag = Paginated<Product>.fromJson(
            {'data': res.data}, Product.fromJson);
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

  void openForm(Product? existing) {
    nameController.text = existing?.namaProduk ?? '';
    priceController.text =
        existing != null ? existing.harga.toString() : '';
    selectedCategory.value =
        existing?.idKategori ?? categories.firstOrNull?.idKategori;
    selectedStatus.value = existing?.status ?? true;

    AppDialog.form(
      title: existing == null ? 'Add Product' : 'Edit Product',
      icon: Icons.fastfood_rounded,
      maxWidth: 440,
      content: ProductForm(controller: this, existing: existing),
      onConfirm: () async {
        await createOrUpdate(existing);
        return false; // createOrUpdate handles closing dialog on success
      },
    );
  }

  Future<void> createOrUpdate(Product? existing) async {
    final nama = nameController.text.trim();
    final hargaText = priceController.text.trim();
    if (nama.isEmpty) {
      EasyLoading.showError('Nama produk required');
      return;
    }
    if (selectedCategory.value == null) {
      EasyLoading.showError('Please choose a category');
      return;
    }
    final harga = double.tryParse(hargaText);
    if (harga == null) {
      EasyLoading.showError('Harga must be a number');
      return;
    }

    EasyLoading.show(status: 'Saving...');
    if (AppConstants.localMode) {
      await _local.saveProduct(
        id: existing?.idProduk,
        categoryId: selectedCategory.value!,
        name: nama,
        price: harga,
        isAvailable: selectedStatus.value,
      );
      EasyLoading.dismiss();
      Get.back();
      EasyLoading.showSuccess('Saved');
      await load();
      return;
    }

    final body = {
      'id_kategori': selectedCategory.value,
      'nama_produk': nama,
      'harga': harga,
      'status': selectedStatus.value ? 1 : 0,
    };

    final res = existing == null
        ? await Get.find<ApiClient>().post('/products', body: body)
        : await Get.find<ApiClient>().put('/products/${existing.idProduk}',
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
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Deleting...');
    if (AppConstants.localMode) {
      await _local.deleteProduct(id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Deleted');
      await load();
      return;
    }
    final res = await Get.find<ApiClient>().delete('/products/$id');
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : 'Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../widgets/product_form.dart';

String money(dynamic v) =>
    'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';

class ProductController extends GetxController {
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
    super.onClose();
  }

  void onSearchChanged(String value) {
    search.value = value;
    page.value = 1;
    load();
  }

  void selectCategory(int? id) {
    selectedCategoryId.value = id;
    page.value = 1;
    load();
  }

  Future<void> loadCategories() async {
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

    Get.dialog(
      AlertDialog(
        title: Text(existing == null ? 'Add Product' : 'Edit Product'),
        content: ProductForm(controller: this, existing: existing),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Save',
            onPressed: () => createOrUpdate(existing),
          ),
        ],
      ),
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

    final body = {
      'id_kategori': selectedCategory.value,
      'nama_produk': nama,
      'harga': harga,
      'status': selectedStatus.value ? 1 : 0,
    };

    EasyLoading.show(status: 'Saving...');
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
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Deleting...');
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

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/models/table.dart';
import '../../../data/models/transaction.dart';
import '../../../data/response/api_response.dart';
import '../controllers/cart_item.dart';

class PosController extends GetxController {
  final ApiClient _api = ApiClient.to;

  final categories = <Category>[].obs;
  final products = <Product>[].obs;
  final tables = <TableModel>[].obs;
  final cart = <CartItem>[].obs;
  final selectedCategoryId = Rxn<int>();
  final selectedTable = Rxn<TableModel>();
  final loading = false.obs;
  final taxRate = AppConstants.taxRate;

  double get subtotal =>
      cart.fold(0, (sum, e) => sum + e.subtotal);
  double get tax => subtotal * taxRate;
  double get grandTotal => subtotal + tax;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadTables();
  }

  Future<void> loadCategories() async {
    final res = await _api.get('/categories', query: {'perPage': 100},
        fromData: (d) => d);
    if (res.success && res.data != null) {
      final pag = Paginated<Category>.fromJson(
          {'data': res.data}, Category.fromJson);
      categories.assignAll(pag.items);
      if (categories.isNotEmpty) {
        selectCategory(categories.first.idKategori);
      }
    }
  }

  Future<void> loadTables() async {
    final res = await _api.get('/meja', query: {'perPage': 100},
        fromData: (d) => d);
    if (res.success && res.data != null) {
      final pag = Paginated<TableModel>.fromJson(
          {'data': res.data}, TableModel.fromJson);
      tables.assignAll(pag.items);
    }
  }

  Future<void> selectCategory(int id) async {
    selectedCategoryId.value = id;
    loading.value = true;
    final res = await _api.get('/products',
        query: {'id_kategori': id, 'perPage': 100}, fromData: (d) => d);
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Product>.fromJson(
          {'data': res.data}, Product.fromJson);
      products.assignAll(pag.items);
    }
  }

  void addToCart(Product product) {
    final idx = cart.indexWhere((e) => e.product.idProduk == product.idProduk);
    if (idx >= 0) {
      cart[idx].qty += 1;
      cart.refresh();
    } else {
      cart.add(CartItem(product: product));
    }
  }

  void incQty(int index) {
    cart[index].qty += 1;
    cart.refresh();
  }

  void decQty(int index) {
    if (cart[index].qty > 1) {
      cart[index].qty -= 1;
    } else {
      cart.removeAt(index);
    }
    cart.refresh();
  }

  void removeItem(int index) => cart.removeAt(index);
  void updateNote(int index, String note) {
    cart[index].note = note;
    cart.refresh();
  }

  void clearCart() => cart.clear();

  Future<void> selectTable() async {
    if (tables.isEmpty) await loadTables();
    final picked = await Get.dialog<TableModel>(
      AlertDialog(
        title: const Text('Select Table'),
        content: SizedBox(
          width: 300.w,
          child: Wrap(
            spacing: 8.w,
            children: tables
                .map((t) => ChoiceChip(
                      label: Text(t.nomorMeja),
                      selected: selectedTable.value?.idMeja == t.idMeja,
                      onSelected: (_) => Get.back(result: t),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (picked != null) selectedTable.value = picked;
  }

  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      EasyLoading.showError('Cart is empty');
      return;
    }
    if (selectedTable.value == null) {
      await selectTable();
      if (selectedTable.value == null) return;
    }

    loading.value = true;
    EasyLoading.show(status: 'Placing order...');
    final res = await _api.post('/transaksi', body: {
      'id_meja': selectedTable.value!.idMeja,
      'items': cart.map((e) => e.toPayload()).toList(),
    }, fromData: (d) => Transaction.fromJson(d as Map<String, dynamic>));
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success && res.data != null) {
      final trx = res.data as Transaction;
      await PrinterService.to.printKitchenTicket(trx);
      clearCart();
      EasyLoading.showSuccess('Order placed');
      Get.toNamed(AppRoutes.payment, arguments: trx);
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/models/table.dart';
import '../../../data/models/transaction.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/utils/debouncer.dart';
import '../controllers/cart_item.dart';
import '../widgets/table_select_sheet.dart';

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

  /// Free-text product search. When non-empty this searches across ALL
  /// categories (the cashier doesn't need to tap a category chip first),
  /// and category selection is temporarily ignored until search is cleared.
  final searchQuery = ''.obs;
  int _searchToken = 0;

  // SECURITY FIX (audit finding #8): search used to fire a network
  // request on every keystroke. A short debounce cuts request volume
  // dramatically for normal typing speed while still feeling instant.
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 300));

  double get subtotal =>
      cart.fold(0, (sum, e) => sum + e.subtotal);
  double get tax => subtotal * taxRate;
  double get grandTotal => subtotal + tax;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadTables();
  }

  @override
  void onClose() {
    _searchDebouncer.dispose();
    super.onClose();
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
    // Picking a category explicitly cancels any active search so the
    // grid reflects the tapped category right away.
    if (isSearching) {
      searchQuery.value = '';
    }
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

  /// Called from the search bar on every keystroke. Empty text restores
  /// the currently selected category's product list immediately (no
  /// debounce needed for clearing — there's no request to throttle).
  /// Non-empty text is debounced before the actual API call fires.
  void onSearchChanged(String value) {
    searchQuery.value = value;
    final query = value.trim();
    if (query.isEmpty) {
      _searchDebouncer.dispose();
      if (selectedCategoryId.value != null) {
        selectCategory(selectedCategoryId.value!);
      }
      return;
    }
    _searchDebouncer.run(() => _searchProducts(query));
  }

  void clearSearch() {
    onSearchChanged('');
  }

  Future<void> _searchProducts(String query) async {
    // Token guard so a slow earlier request can't overwrite a newer one
    // if the cashier keeps typing quickly.
    final token = ++_searchToken;
    loading.value = true;
    final res = await _api.get('/products',
        query: {'q': query, 'perPage': 100}, fromData: (d) => d);
    if (token != _searchToken) return; // a newer search superseded this one
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Product>.fromJson(
          {'data': res.data}, Product.fromJson);
      products.assignAll(pag.items);
    } else {
      EasyLoading.showError(res.message);
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
      TableSelectSheet(tables: tables, selectedId: selectedTable.value?.idMeja),
    );
    if (picked != null) {
      selectedTable.value = picked;
      isTakeaway.value = false;
    }
  }

  /// UX FIX (design review P0 #2): previously there was no way to place
  /// a takeaway order without first opening the full table-picker sheet
  /// and somehow knowing there was a "no table" option buried in it (and
  /// as written, `placeOrder()` didn't actually have one — it always
  /// required a non-null `TableModel`). Cashiers doing high-volume
  /// takeaway business had to go through the table sheet on every single
  /// order regardless.
  ///
  /// `setTakeaway()` explicitly clears `selectedTable` to null and marks
  /// intent via `isTakeaway`, so `placeOrder()` can skip the table-sheet
  /// requirement entirely for this order. A dedicated flag (rather than
  /// just "table is null") makes the UI's takeaway button state and the
  /// order-payload logic both explicit instead of relying on the same
  /// null value to mean two different things ("nothing selected yet" vs
  /// "deliberately no table").
  final isTakeaway = false.obs;

  void setTakeaway() {
    selectedTable.value = null;
    isTakeaway.value = true;
  }

  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      EasyLoading.showError('Cart is empty');
      return;
    }
    if (!isTakeaway.value && selectedTable.value == null) {
      await selectTable();
      if (selectedTable.value == null) return;
    }

    loading.value = true;
    EasyLoading.show(status: 'Placing order...');
    final res = await _api.post('/transaksi', body: {
      // NOTE ON BACKEND CONTRACT: for takeaway orders `id_meja` is
      // omitted from the body entirely (not sent as a literal `null`
      // key) since that's the safest default assumption for a Laravel
      // API validating an optional/nullable foreign key. If your
      // `/transaksi` endpoint instead expects a specific placeholder
      // table id or a literal `"id_meja": null` key present, this is
      // the one line to change — confirm against the actual
      // TransaksiController validation rules before relying on this in
      // production.
      if (!isTakeaway.value) 'id_meja': selectedTable.value!.idMeja,
      'items': cart.map((e) => e.toPayload()).toList(),
    }, fromData: (d) => Transaction.fromJson(d as Map<String, dynamic>));
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success && res.data != null) {
      final trx = res.data as Transaction;
      await PrinterService.to.printKitchenTicket(trx);
      clearCart();
      isTakeaway.value = false;
      EasyLoading.showSuccess('Order placed');
      Get.toNamed(AppRoutes.payment, arguments: trx);
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/offline_queue_service.dart';
import '../../../app/services/print_queue_service.dart';
import '../../../data/models/category.dart';
import '../../../data/models/product.dart';
import '../../../data/models/table.dart';
import '../../../data/models/transaction.dart';
import '../../../data/response/api_response.dart';
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
  /// the currently selected category's product list.
  void onSearchChanged(String value) {
    searchQuery.value = value;
    final query = value.trim();
    if (query.isEmpty) {
      if (selectedCategoryId.value != null) {
        selectCategory(selectedCategoryId.value!);
      }
      return;
    }
    _searchProducts(query);
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

  /// UI CHANGE: previously opened a stock `AlertDialog` with a `Wrap` of
  /// generic `ChoiceChip`s — functional, but visually inconsistent with
  /// the rest of the app (no glass surface, no brand accent, no per-table
  /// status indicator) and cramped once there were more than a handful
  /// of tables. Now opens [TableSelectSheet], a dedicated glass card grid
  /// with per-table capacity, a status dot (available/occupied/reserved/
  /// cleaning), and the same salmon-gradient selected state used
  /// everywhere else in the app. The return contract is unchanged: it
  /// resolves to the picked [TableModel] or `null` if dismissed.
  Future<void> selectTable() async {
    if (tables.isEmpty) await loadTables();
    final picked = await Get.dialog<TableModel>(
      TableSelectSheet(tables: tables, selectedId: selectedTable.value?.idMeja),
    );
    if (picked != null) selectedTable.value = picked;
  }

  /// OFFLINE QUEUE (this pass): previously a failed `POST /transaksi`
  /// (e.g. WiFi drops at the table) just surfaced `EasyLoading.showError`
  /// and the whole order — everything the cashier just entered — was
  /// gone with nothing to retry. That's a real problem for a restaurant
  /// POS where connectivity to the counter isn't always reliable.
  ///
  /// Behavior now:
  ///  1. Try the request normally, exactly as before.
  ///  2. On success: unchanged (print ticket, clear cart, go to payment).
  ///  3. On failure that looks like a CONNECTIVITY problem (see
  ///     `_isLikelyOffline`): save the order to `OfflineQueueService`
  ///     (sqflite-backed) and clear the cart so the cashier can keep
  ///     taking new orders. Nothing is printed yet — printing happens
  ///     once `SyncService` successfully sends the order later.
  ///  4. On failure that looks like a real SERVER rejection (validation,
  ///     stock, auth, etc.): shown to the cashier immediately, same as
  ///     before. These are deliberately NOT queued, since resending an
  ///     invalid payload later would just fail again silently.
  Future<void> placeOrder() async {
    if (cart.isEmpty) {
      EasyLoading.showError('Cart is empty');
      return;
    }
    if (selectedTable.value == null) {
      await selectTable();
      if (selectedTable.value == null) return;
    }

    final items = cart.map((e) => e.toPayload()).toList();
    final idMeja = selectedTable.value!.idMeja;

    loading.value = true;
    EasyLoading.show(status: 'Placing order...');
    final res = await _api.post('/transaksi', body: {
      'id_meja': idMeja,
      'items': items,
    }, fromData: (d) => Transaction.fromJson(d as Map<String, dynamic>));
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success && res.data != null) {
      final trx = res.data as Transaction;
      await PrintQueueService.to.printKitchenTicket(trx);
      clearCart();
      EasyLoading.showSuccess('Order placed');
      Get.toNamed(AppRoutes.payment, arguments: trx);
      return;
    }

    if (_isLikelyOffline(res.message)) {
      await OfflineQueueService.to.enqueue(idMeja: idMeja, items: items);
      clearCart();
      EasyLoading.showInfo(
        'No connection — order saved locally and will sync automatically.',
      );
      return;
    }

    EasyLoading.showError(res.message);
  }

  /// Distinguishes "couldn't reach the server" from "server rejected the
  /// request". `ApiClient._send()` (api_client.dart) sets these exact
  /// messages for Dio failures that never got a real HTTP response back
  /// (network error, timeout, bad/pinned certificate), as opposed to a
  /// 4xx/5xx response body with a business-logic `message`. Only the
  /// former should ever be queued for silent retry.
  bool _isLikelyOffline(String message) {
    const networkErrorMarkers = [
      'Network error',
      'Koneksi tidak aman terdeteksi', // SSL pinning reject, see ssl_pinning_interceptor.dart
      'SocketException',
      'Connection timed out',
      'Connection refused',
      'Failed host lookup',
    ];
    return networkErrorMarkers.any((m) => message.contains(m));
  }
}

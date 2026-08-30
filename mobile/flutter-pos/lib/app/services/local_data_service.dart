import 'package:get/get.dart';
import '../../data/models/category.dart';
import '../../data/models/closing.dart';
import '../../data/models/expense.dart';
import '../../data/models/ingredient.dart';
import '../../data/models/payment.dart';
import '../../data/models/product.dart';
import '../../data/models/role.dart';
import '../../data/models/shift.dart';
import '../../data/models/stock.dart';
import '../../data/models/table.dart';
import '../../data/models/transaction.dart';
import '../../data/models/user.dart';
import 'database_helper.dart';

/// Result of a local (non-HTTP) auth attempt. Kept separate from
/// [AuthSession] in `auth_service.dart` so this service has no
/// dependency on that file (avoids an import cycle).
class LocalAuthResult {
  final String token;
  final User user;
  LocalAuthResult({required this.token, required this.user});
}

/// Single façade over [DatabaseHelper] used by every controller in
/// local/offline mode. Each method returns the SAME model types
/// (`Category`, `Product`, `Shift`, `Transaction`, ...) the app already
/// uses for the online/API path, so a controller's local-mode branch can
/// assign the result straight into its `.obs` list/state without any
/// extra mapping.
///
/// REPLACES the previous partial version of this file, which only
/// covered Category/Product/Table/a bare-bones Transaction and left
/// Ingredient, Stock, Shift, Payment methods, Expense, Closing and
/// Report returning empty ("Not available in local mode"). Every one of
/// those is now backed by real SQLite tables (see `database_helper.dart`)
/// so the whole app works fully offline.
class LocalDataService extends GetxService {
  static LocalDataService get to => Get.find<LocalDataService>();

  DatabaseHelper get _db => DatabaseHelper.to;

  // ---- Auth ------------------------------------------------------------

  Future<LocalAuthResult?> login(String username, String password) async {
    final rows = await _db.query(
      'users',
      where: 'username = ? AND password = ? AND status = 1',
      whereArgs: [username, password],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;

    final roleRows = await _db.query(
      'roles',
      where: 'id_role = ?',
      whereArgs: [row['id_role']],
    );
    final role = roleRows.isNotEmpty
        ? Role.fromJson(roleRows.first)
        : null;

    final user = User(
      idUser: row['id_user'] as int,
      idRole: row['id_role'] as int,
      nama: row['nama'] as String,
      username: row['username'] as String,
      status: (row['status'] as int) == 1,
      role: role,
    );
    // No real server session in local mode — a stable per-user token is
    // enough for `SecureStorageService`/`ApiClient` (unused here, but
    // some widgets read `token` just to know "is logged in").
    return LocalAuthResult(token: 'local-session-${user.idUser}', user: user);
  }

  // ---- Categories --------------------------------------------------------

  Future<List<Category>> getAppCategories() async {
    final rows = await _db.query('kategori', orderBy: 'nama_kategori ASC');
    return rows.map(Category.fromJson).toList();
  }

  Future<void> saveCategory({int? id, required String name, String? description, bool status = true}) async {
    final data = {
      'nama_kategori': name,
      'deskripsi': description,
      'status': status ? 1 : 0,
    };
    if (id == null) {
      await _db.insert('kategori', data);
    } else {
      await _db.update('kategori', data, where: 'id_kategori = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteCategory(int id) async {
    await _db.delete('kategori', where: 'id_kategori = ?', whereArgs: [id]);
  }

  // ---- Products ------------------------------------------------------------

  Future<List<Product>> getAppProducts() async {
    final rows = await _db.query('produk', orderBy: 'nama_produk ASC');
    final categories = {for (final c in await getAppCategories()) c.idKategori: c};
    return rows.map((row) {
      final product = Product.fromJson(row);
      final category = categories[product.idKategori];
      return category == null
          ? product
          : Product(
              idProduk: product.idProduk,
              idKategori: product.idKategori,
              namaProduk: product.namaProduk,
              harga: product.harga,
              gambar: product.gambar,
              status: product.status,
              category: category,
              recipes: product.recipes,
            );
    }).toList();
  }

  /// Price is stored/read as plain rupiah (matches `Product.harga` and
  /// every `Rp ${harga.toStringAsFixed(0)}` display in the UI). The
  /// previous version of this service multiplied by 100 before saving,
  /// which silently inflated every saved price 100x — fixed here.
  Future<void> saveProduct({
    int? id,
    required int categoryId,
    required String name,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    final data = {
      'id_kategori': categoryId,
      'nama_produk': name,
      'harga': price,
      'gambar': imageUrl,
      'status': isAvailable ? 1 : 0,
    };
    if (id == null) {
      await _db.insert('produk', data);
    } else {
      await _db.update('produk', data, where: 'id_produk = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteProduct(int id) async {
    await _db.delete('produk', where: 'id_produk = ?', whereArgs: [id]);
  }

  // ---- Ingredients (bahan baku) -----------------------------------------

  Future<List<Ingredient>> getAppIngredients({String search = ''}) async {
    final all = await _db.query('bahan_baku', orderBy: 'nama_bahan ASC');
    final rows = search.trim().isEmpty
        ? all
        : all.where((r) => (r['nama_bahan'] as String).toLowerCase().contains(search.trim().toLowerCase())).toList();
    return rows.map(Ingredient.fromJson).toList();
  }

  Future<void> saveIngredient({
    int? id,
    required String name,
    required String unit,
    required double minimalStock,
  }) async {
    final data = {
      'nama_bahan': name,
      'satuan': unit,
      'minimal_stok': minimalStock,
    };
    if (id == null) {
      await _db.insert('bahan_baku', data);
    } else {
      await _db.update('bahan_baku', data, where: 'id_bahan = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteIngredient(int id) async {
    await _db.delete('bahan_baku', where: 'id_bahan = ?', whereArgs: [id]);
  }

  // ---- Stock (stok bahan) -----------------------------------------------

  Future<List<Stock>> getAppStock({String search = ''}) async {
    final rows = await _db.query('stok_bahan', orderBy: 'id_stok ASC');
    final ingredients = {for (final i in await getAppIngredients()) i.idBahan: i};
    var items = rows.map((row) {
      final stock = Stock.fromJson(row);
      final ingredient = ingredients[stock.idBahan];
      return Stock(
        idStok: stock.idStok,
        idBahan: stock.idBahan,
        jumlah: stock.jumlah,
        ingredient: ingredient,
      );
    }).toList();
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((s) => (s.ingredient?.namaBahan ?? '').toLowerCase().contains(q)).toList();
    }
    return items;
  }

  Future<void> addStockAdjustment({required int ingredientId, required double jumlah}) async {
    // Mirrors the Laravel endpoint semantics: POST /stok-bahan creates a
    // new stock row for the ingredient rather than merging into an
    // existing one, so history of adjustments is preserved.
    await _db.insert('stok_bahan', {'id_bahan': ingredientId, 'jumlah': jumlah});
  }

  Future<void> updateStock(int stockId, double jumlah) async {
    await _db.update('stok_bahan', {'jumlah': jumlah}, where: 'id_stok = ?', whereArgs: [stockId]);
  }

  Future<void> deleteStock(int stockId) async {
    await _db.delete('stok_bahan', where: 'id_stok = ?', whereArgs: [stockId]);
  }

  // ---- Tables (meja) -------------------------------------------------------

  Future<List<TableModel>> getAppTables() async {
    final rows = await _db.query('meja', orderBy: 'nomor_meja ASC');
    return rows.map(TableModel.fromJson).toList();
  }

  Future<void> saveTable({int? id, required String name, required int capacity, required String status}) async {
    final data = {'nomor_meja': name, 'kapasitas': capacity, 'status': status};
    if (id == null) {
      await _db.insert('meja', data);
    } else {
      await _db.update('meja', data, where: 'id_meja = ?', whereArgs: [id]);
    }
  }

  Future<void> deleteTable(int id) async {
    await _db.delete('meja', where: 'id_meja = ?', whereArgs: [id]);
  }

  Future<void> setTableStatus(int id, String status) async {
    await _db.update('meja', {'status': status}, where: 'id_meja = ?', whereArgs: [id]);
  }

  // ---- Shift -------------------------------------------------------------

  Future<Shift?> getActiveShift(int userId) async {
    final rows = await _db.query(
      'shift',
      where: 'id_user = ? AND status = ?',
      whereArgs: [userId, 'open'],
      orderBy: 'id_shift DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Shift.fromJson(rows.first);
  }

  Future<Shift?> getShiftById(int id) async {
    final rows = await _db.query('shift', where: 'id_shift = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Shift.fromJson(rows.first);
  }

  Future<Shift> openShift({required int userId, required double pettyCash}) async {
    final id = await _db.insert('shift', {
      'id_user': userId,
      'open_time': DateTime.now().toIso8601String(),
      'close_time': null,
      'petty_cash': pettyCash,
      'status': 'open',
    });
    return (await getShiftById(id))!;
  }

  Future<void> addPettyCash(int shiftId, double nominal) async {
    final shift = await getShiftById(shiftId);
    if (shift == null) return;
    await _db.update(
      'shift',
      {'petty_cash': shift.pettyCash + nominal},
      where: 'id_shift = ?',
      whereArgs: [shiftId],
    );
  }

  Future<void> closeShift(int shiftId) async {
    await _db.update(
      'shift',
      {'close_time': DateTime.now().toIso8601String(), 'status': 'closed'},
      where: 'id_shift = ?',
      whereArgs: [shiftId],
    );
  }

  // ---- Transactions (POS) -------------------------------------------------

  Future<Transaction> createTransaction({
    required int shiftId,
    required int userId,
    required int tableId,
    required List<Map<String, dynamic>> items, // [{id_produk, qty, harga, catatan?}]
  }) async {
    final now = DateTime.now();
    final invoiceNumber =
        'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch % 100000}';
    final total = items.fold<double>(
      0,
      (sum, it) => sum + ((it['harga'] as num).toDouble() * (it['qty'] as int)),
    );

    final txId = await _db.insert('transaksi', {
      'invoice_number': invoiceNumber,
      'id_shift': shiftId,
      'id_user': userId,
      'id_meja': tableId,
      'tanggal': now.toIso8601String(),
      'total': total,
      'status': 'pending',
    });

    for (final it in items) {
      final qty = it['qty'] as int;
      final harga = (it['harga'] as num).toDouble();
      await _db.insert('transaksi_detail', {
        'id_transaksi': txId,
        'id_produk': it['id_produk'] as int,
        'qty': qty,
        'harga': harga,
        'subtotal': harga * qty,
        'catatan': it['catatan'] as String?,
      });
    }

    await setTableStatus(tableId, 'occupied');

    return (await getTransactionById(txId))!;
  }

  Future<Transaction?> getTransactionById(int id) async {
    final rows = await _db.query('transaksi', where: 'id_transaksi = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _hydrateTransaction(rows.first);
  }

  Future<List<Transaction>> getTransactions({int? shiftId, String? status}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (shiftId != null) {
      where.add('id_shift = ?');
      args.add(shiftId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    final rows = await _db.query(
      'transaksi',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: where.isEmpty ? null : args,
      orderBy: 'id_transaksi DESC',
    );
    final result = <Transaction>[];
    for (final row in rows) {
      result.add(await _hydrateTransaction(row));
    }
    return result;
  }

  Future<Transaction> _hydrateTransaction(Map<String, dynamic> row) async {
    final detailRows = await _db.query(
      'transaksi_detail',
      where: 'id_transaksi = ?',
      whereArgs: [row['id_transaksi']],
    );
    final products = {for (final p in await getAppProducts()) p.idProduk: p};
    final details = detailRows
        .map((d) => TransactionDetail(
              idDetail: d['id_detail'] as int,
              idTransaksi: d['id_transaksi'] as int,
              idProduk: d['id_produk'] as int,
              qty: d['qty'] as int,
              harga: (d['harga'] as num).toDouble(),
              subtotal: (d['subtotal'] as num).toDouble(),
              catatan: d['catatan'] as String?,
              product: products[d['id_produk']],
            ))
        .toList();

    final tableRows = await _db.query('meja', where: 'id_meja = ?', whereArgs: [row['id_meja']]);
    final table = tableRows.isNotEmpty ? TableModel.fromJson(tableRows.first) : null;

    final userRows = await _db.query('users', where: 'id_user = ?', whereArgs: [row['id_user']]);
    final user = userRows.isNotEmpty
        ? User(
            idUser: userRows.first['id_user'] as int,
            idRole: userRows.first['id_role'] as int,
            nama: userRows.first['nama'] as String,
            username: userRows.first['username'] as String,
            status: (userRows.first['status'] as int) == 1,
          )
        : null;

    final paymentRows = await _db.query('pembayaran', where: 'id_transaksi = ?', whereArgs: [row['id_transaksi']]);
    Payment? payment;
    if (paymentRows.isNotEmpty) {
      final pRow = paymentRows.first;
      final methodRows = await _db.query('metode_pembayaran', where: 'id_metode = ?', whereArgs: [pRow['id_metode']]);
      payment = Payment(
        idPembayaran: pRow['id_pembayaran'] as int,
        idTransaksi: pRow['id_transaksi'] as int,
        idMetode: pRow['id_metode'] as int,
        totalBayar: (pRow['total_bayar'] as num).toDouble(),
        uangDiterima: (pRow['uang_diterima'] as num).toDouble(),
        kembalian: (pRow['kembalian'] as num).toDouble(),
        waktuBayar: pRow['waktu_bayar'] as String?,
        status: pRow['status'] as String,
        method: methodRows.isNotEmpty ? PaymentMethod.fromJson(methodRows.first) : null,
      );
    }

    return Transaction(
      idTransaksi: row['id_transaksi'] as int,
      invoiceNumber: row['invoice_number'] as String,
      idShift: row['id_shift'] as int,
      idUser: row['id_user'] as int,
      idMeja: row['id_meja'] as int,
      tanggal: row['tanggal'] as String,
      total: (row['total'] as num).toDouble(),
      status: row['status'] as String,
      details: details,
      table: table,
      user: user,
      payment: payment,
    );
  }

  /// Marks an order voided/cancelled/paid etc. When `reason` is given
  /// (used by `VoidOrderController`) it's persisted alongside the status
  /// change instead of being silently discarded.
  Future<void> updateTransactionStatus(int id, String status, {String? reason}) async {
    final data = <String, dynamic>{'status': status};
    if (reason != null) data['void_reason'] = reason;
    await _db.update('transaksi', data, where: 'id_transaksi = ?', whereArgs: [id]);
  }

  // ---- Payments ------------------------------------------------------------

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final rows = await _db.query('metode_pembayaran', where: 'status = 1', orderBy: 'id_metode ASC');
    return rows.map(PaymentMethod.fromJson).toList();
  }

  Future<Payment> payTransaction({
    required int transactionId,
    required int methodId,
    required double totalBayar,
    required double uangDiterima,
    required double kembalian,
  }) async {
    final id = await _db.insert('pembayaran', {
      'id_transaksi': transactionId,
      'id_metode': methodId,
      'total_bayar': totalBayar,
      'uang_diterima': uangDiterima,
      'kembalian': kembalian,
      'waktu_bayar': DateTime.now().toIso8601String(),
      'status': 'paid',
    });

    await _db.update('transaksi', {'status': 'paid'}, where: 'id_transaksi = ?', whereArgs: [transactionId]);

    // Free the table back up now that the order is settled.
    final txRows = await _db.query('transaksi', where: 'id_transaksi = ?', whereArgs: [transactionId]);
    if (txRows.isNotEmpty) {
      await setTableStatus(txRows.first['id_meja'] as int, 'available');
    }

    final rows = await _db.query('pembayaran', where: 'id_pembayaran = ?', whereArgs: [id]);
    final methodRows = await _db.query('metode_pembayaran', where: 'id_metode = ?', whereArgs: [methodId]);
    final row = rows.first;
    return Payment(
      idPembayaran: row['id_pembayaran'] as int,
      idTransaksi: row['id_transaksi'] as int,
      idMetode: row['id_metode'] as int,
      totalBayar: (row['total_bayar'] as num).toDouble(),
      uangDiterima: (row['uang_diterima'] as num).toDouble(),
      kembalian: (row['kembalian'] as num).toDouble(),
      waktuBayar: row['waktu_bayar'] as String?,
      status: row['status'] as String,
      method: methodRows.isNotEmpty ? PaymentMethod.fromJson(methodRows.first) : null,
    );
  }

  // ---- Expenses (pengeluaran) --------------------------------------------

  Future<List<Expense>> getExpenses({int? shiftId}) async {
    final rows = await _db.query(
      'pengeluaran',
      where: shiftId != null ? 'id_shift = ?' : null,
      whereArgs: shiftId != null ? [shiftId] : null,
      orderBy: 'id_pengeluaran DESC',
    );
    return rows.map(Expense.fromJson).toList();
  }

  Future<void> addExpense({
    required int shiftId,
    required String kategori,
    required double nominal,
    String? keterangan,
  }) async {
    await _db.insert('pengeluaran', {
      'id_shift': shiftId,
      'kategori': kategori,
      'nominal': nominal,
      'keterangan': keterangan,
      'tanggal': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteExpense(int id) async {
    await _db.delete('pengeluaran', where: 'id_pengeluaran = ?', whereArgs: [id]);
  }

  // ---- Closing -------------------------------------------------------------

  Future<List<Closing>> getClosingHistory() async {
    final rows = await _db.query('closing', orderBy: 'id_closing DESC');
    return rows.map(Closing.fromJson).toList();
  }

  /// Idempotent: if a closing report already exists for this shift it is
  /// returned as-is instead of being duplicated (mirrors the comment in
  /// `ClosingController`/`closing_page.dart` about `/shifts/{id}/closing`
  /// being idempotent server-side).
  Future<Closing> generateClosing(int shiftId) async {
    final existing = await _db.query('closing', where: 'id_shift = ?', whereArgs: [shiftId]);
    if (existing.isNotEmpty) {
      return Closing.fromJson(existing.first);
    }

    final transactions = await getTransactions(shiftId: shiftId, status: 'paid');
    final totalPenjualan = transactions.fold<double>(0, (sum, t) => sum + t.total);

    double totalCash = 0;
    double totalQris = 0;
    for (final t in transactions) {
      final methodName = t.payment?.method?.namaMetode ?? '';
      if (methodName == 'Cash') {
        totalCash += t.payment?.totalBayar ?? t.total;
      } else if (methodName == 'QRIS') {
        totalQris += t.payment?.totalBayar ?? t.total;
      }
    }

    final expenses = await getExpenses(shiftId: shiftId);
    final totalPengeluaran = expenses.fold<double>(0, (sum, e) => sum + e.nominal);

    final shift = await getShiftById(shiftId);
    final saldoAkhir = (shift?.pettyCash ?? 0) + totalCash - totalPengeluaran;

    final id = await _db.insert('closing', {
      'id_shift': shiftId,
      'total_penjualan': totalPenjualan,
      'total_cash': totalCash,
      'total_qris': totalQris,
      'total_pengeluaran': totalPengeluaran,
      'saldo_akhir': saldoAkhir,
      'waktu_closing': DateTime.now().toIso8601String(),
      'status': 'closed',
    });

    await closeShift(shiftId);

    final rows = await _db.query('closing', where: 'id_closing = ?', whereArgs: [id]);
    return Closing.fromJson(rows.first);
  }

  // ---- Reports -------------------------------------------------------------

  Future<Map<String, dynamic>> getDailyReport() async {
    final startOfDay = DateTime.now().toIso8601String().substring(0, 10);
    return _reportFor(startOfDay, startOfDay);
  }

  Future<Map<String, dynamic>> getLast7DaysReport() async {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final labels = days.map((d) => d.toIso8601String().substring(0, 10)).toList();
    final totals = <double>[];
    for (final label in labels) {
      final report = await _reportFor(label, label);
      totals.add((report['sales'] as num).toDouble());
    }
    return {'days': labels, 'totals': totals};
  }

  Future<Map<String, dynamic>> getMonthlyReport() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
    final end = now.toIso8601String().substring(0, 10);
    return _reportFor(start, end);
  }

  Future<Map<String, dynamic>> _reportFor(String startDate, String endDate) async {
    final rows = await _db.rawQuery(
      '''
      SELECT * FROM transaksi
      WHERE status = 'paid' AND substr(tanggal, 1, 10) BETWEEN ? AND ?
      ''',
      [startDate, endDate],
    );

    double sales = 0;
    double cash = 0;
    double qris = 0;
    for (final row in rows) {
      final total = (row['total'] as num).toDouble();
      sales += total;
      final payRows = await _db.query('pembayaran', where: 'id_transaksi = ?', whereArgs: [row['id_transaksi']]);
      if (payRows.isNotEmpty) {
        final methodRows = await _db.query('metode_pembayaran', where: 'id_metode = ?', whereArgs: [payRows.first['id_metode']]);
        final methodName = methodRows.isNotEmpty ? methodRows.first['nama_metode'] as String : '';
        if (methodName == 'Cash') {
          cash += total;
        } else if (methodName == 'QRIS') {
          qris += total;
        }
      }
    }

    final expenseRows = await _db.rawQuery(
      '''
      SELECT * FROM pengeluaran
      WHERE substr(tanggal, 1, 10) BETWEEN ? AND ?
      ''',
      [startDate, endDate],
    );
    final expenses = expenseRows.fold<double>(0, (sum, r) => sum + (r['nominal'] as num).toDouble());

    return {
      'sales': sales,
      'orders': rows.length,
      'cash': cash,
      'qris': qris,
      'expenses': expenses,
    };
  }

  // ---- Dashboard -------------------------------------------------------------

  /// Shape matches what `dashboard_page.dart` reads directly
  /// (`totalSales`, `transactions`, `products`, `expenses`, `salesTrend`,
  /// `topProducts`) — the previous local-mode payload used different key
  /// names (`total_orders`, `total_revenue`, ...) that the view never
  /// actually read, so the admin dashboard silently showed zeros.
  Future<Map<String, dynamic>> getAdminDashboard() async {
    final last7 = await getLast7DaysReport();
    final days = (last7['days'] as List).cast<String>();
    final totals = (last7['totals'] as List).cast<double>();
    final salesTrend = {for (var i = 0; i < days.length; i++) days[i]: totals[i]};

    final today = await getDailyReport();
    final products = await getAppProducts();
    final expenses = await getExpenses();
    final todayExpenses = expenses.where((e) => e.tanggal.startsWith(DateTime.now().toIso8601String().substring(0, 10)));
    final totalExpensesToday = todayExpenses.fold<double>(0, (sum, e) => sum + e.nominal);

    final paidTransactions = await getTransactions(status: 'paid');
    final qtyByProduct = <int, int>{};
    for (final t in paidTransactions) {
      for (final d in t.details ?? const <TransactionDetail>[]) {
        qtyByProduct[d.idProduk] = (qtyByProduct[d.idProduk] ?? 0) + d.qty;
      }
    }
    final productsById = {for (final p in products) p.idProduk: p};
    final topProducts = (qtyByProduct.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => {
              'nama_produk': productsById[e.key]?.namaProduk ?? 'Produk #${e.key}',
              'qty': e.value,
            })
        .toList();

    return {
      'totalSales': today['sales'],
      'transactions': today['orders'],
      'products': products.length,
      'expenses': totalExpensesToday,
      'salesTrend': salesTrend,
      'topProducts': topProducts,
    };
  }

  /// Shape matches `dashboard_page.dart`'s cashier branch
  /// (`currentShift`, `salesToday`, `ordersToday`).
  Future<Map<String, dynamic>> getCashierDashboard(int userId) async {
    final shift = await getActiveShift(userId);
    final today = await getDailyReport();
    return {
      'currentShift': shift != null ? {'id_shift': shift.idShift} : null,
      'salesToday': today['sales'],
      'ordersToday': today['orders'],
    };
  }
}

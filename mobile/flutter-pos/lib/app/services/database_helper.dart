import 'dart:async';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Single local SQLite database for the whole app.
///
/// REPLACES the Laravel backend as the app's only data source
/// (`AppConstants.localMode` is now always effectively `true` — every
/// module reads/writes here instead of hitting `/api/*`). The schema
/// below mirrors the original Laravel tables 1:1 (same column names as
/// the JSON keys the Dart models already expect via `fromJson`), so the
/// per-module repositories in `lib/data/local/` can hand rows straight
/// back to `Category.fromJson`, `Product.fromJson`, etc. without any
/// remapping.
///
/// NOTE: `mobile/laravel-api` (the original backend) is intentionally
/// left untouched on disk for future re-enablement (e.g. multi-device
/// sync) — nothing in this file or its callers deletes or depends on
/// that folder.
class DatabaseHelper extends GetxService {
  static DatabaseHelper get to => Get.find<DatabaseHelper>();

  static const _dbName = 'sushimoo_pos.db';
  static const _dbVersion = 2;

  Database? _db;
  final Completer<void> _ready = Completer<void>();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  /// Resolves once the DB has been created/opened AND seeded (if it was
  /// empty). Splash/initial binding can await this before routing.
  Future<void> get ready => _ready.future;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    try {
      await database;
      if (!_ready.isCompleted) _ready.complete();
    } catch (e) {
      // DB open/upgrade threw (e.g. a previous failed migration left the
      // schema in a partial state). Delete the corrupt file and recreate
      // from scratch so the app can always start cleanly.
      try {
        final dbPath = await getDatabasesPath();
        final path = p.join(dbPath, _dbName);
        await deleteDatabase(path);
        _db = null;
        await database; // re-open → triggers onCreate + seed
        if (!_ready.isCompleted) _ready.complete();
      } catch (e2) {
        if (!_ready.isCompleted) _ready.completeError(e2);
      }
    }
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Migration from v1 → v2: make `id_meja` nullable in `transaksi` so
  /// takeaway orders (no physical table) can be placed in offline mode.
  ///
  /// IMPORTANT: sqflite wraps `onUpgrade` in a transaction, and SQLite
  /// ignores `PRAGMA foreign_keys = OFF` inside a transaction. To drop
  /// `transaksi` without violating the FK from `transaksi_detail`, we
  /// must drop the child table first, then the parent, then recreate
  /// both (preserving existing rows via temp tables).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1. Back up child rows (transaksi_detail → transaksi_detail_bak)
      await db.execute('''
        CREATE TABLE transaksi_detail_bak AS
          SELECT * FROM transaksi_detail
      ''');

      // 2. Back up parent rows with new nullable schema
      await db.execute('''
        CREATE TABLE transaksi_new (
          id_transaksi INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_number TEXT NOT NULL,
          id_shift INTEGER NOT NULL,
          id_user INTEGER NOT NULL,
          id_meja INTEGER,
          tanggal TEXT NOT NULL,
          total REAL NOT NULL DEFAULT 0,
          status TEXT NOT NULL DEFAULT 'pending',
          void_reason TEXT,
          FOREIGN KEY (id_shift) REFERENCES shift (id_shift),
          FOREIGN KEY (id_user) REFERENCES users (id_user),
          FOREIGN KEY (id_meja) REFERENCES meja (id_meja)
        )
      ''');
      await db.execute('''
        INSERT INTO transaksi_new
          SELECT id_transaksi, invoice_number, id_shift, id_user,
                 id_meja, tanggal, total, status, void_reason
          FROM transaksi
      ''');

      // 3. Drop child FIRST (removes FK dependency on transaksi)
      await db.execute('DROP TABLE transaksi_detail');
      // 4. Now safe to drop parent
      await db.execute('DROP TABLE transaksi');

      // 5. Promote the new tables
      await db.execute('ALTER TABLE transaksi_new RENAME TO transaksi');
      await db.execute('''
        CREATE TABLE transaksi_detail (
          id_detail INTEGER PRIMARY KEY AUTOINCREMENT,
          id_transaksi INTEGER NOT NULL,
          id_produk INTEGER NOT NULL,
          qty INTEGER NOT NULL DEFAULT 1,
          harga REAL NOT NULL DEFAULT 0,
          subtotal REAL NOT NULL DEFAULT 0,
          catatan TEXT,
          FOREIGN KEY (id_transaksi) REFERENCES transaksi (id_transaksi),
          FOREIGN KEY (id_produk) REFERENCES produk (id_produk)
        )
      ''');
      await db.execute('''
        INSERT INTO transaksi_detail
          SELECT id_detail, id_transaksi, id_produk,
                 qty, harga, subtotal, catatan
          FROM transaksi_detail_bak
      ''');
      await db.execute('DROP TABLE transaksi_detail_bak');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    batch.execute('''
      CREATE TABLE roles (
        id_role INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_role TEXT NOT NULL UNIQUE,
        deskripsi TEXT
      )
    ''');

    batch.execute('''
      CREATE TABLE users (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        id_role INTEGER NOT NULL,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_role) REFERENCES roles (id_role)
      )
    ''');

    batch.execute('''
      CREATE TABLE kategori (
        id_kategori INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_kategori TEXT NOT NULL,
        deskripsi TEXT,
        status INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE TABLE produk (
        id_produk INTEGER PRIMARY KEY AUTOINCREMENT,
        id_kategori INTEGER NOT NULL,
        nama_produk TEXT NOT NULL,
        harga REAL NOT NULL DEFAULT 0,
        gambar TEXT,
        status INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_kategori) REFERENCES kategori (id_kategori)
      )
    ''');

    batch.execute('''
      CREATE TABLE bahan_baku (
        id_bahan INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_bahan TEXT NOT NULL,
        satuan TEXT NOT NULL,
        minimal_stok REAL NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE resep (
        id_resep INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produk INTEGER NOT NULL,
        id_bahan INTEGER NOT NULL,
        qty REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (id_produk) REFERENCES produk (id_produk),
        FOREIGN KEY (id_bahan) REFERENCES bahan_baku (id_bahan)
      )
    ''');

    batch.execute('''
      CREATE TABLE stok_bahan (
        id_stok INTEGER PRIMARY KEY AUTOINCREMENT,
        id_bahan INTEGER NOT NULL,
        jumlah REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (id_bahan) REFERENCES bahan_baku (id_bahan)
      )
    ''');

    batch.execute('''
      CREATE TABLE meja (
        id_meja INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_meja TEXT NOT NULL,
        kapasitas INTEGER NOT NULL DEFAULT 4,
        status TEXT NOT NULL DEFAULT 'available'
      )
    ''');

    batch.execute('''
      CREATE TABLE shift (
        id_shift INTEGER PRIMARY KEY AUTOINCREMENT,
        id_user INTEGER NOT NULL,
        open_time TEXT,
        close_time TEXT,
        petty_cash REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'open',
        FOREIGN KEY (id_user) REFERENCES users (id_user)
      )
    ''');

    batch.execute('''
      CREATE TABLE metode_pembayaran (
        id_metode INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_metode TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1
      )
    ''');

    batch.execute('''
      CREATE TABLE transaksi (
        id_transaksi INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL,
        id_shift INTEGER NOT NULL,
        id_user INTEGER NOT NULL,
        id_meja INTEGER,
        tanggal TEXT NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        void_reason TEXT,
        FOREIGN KEY (id_shift) REFERENCES shift (id_shift),
        FOREIGN KEY (id_user) REFERENCES users (id_user),
        FOREIGN KEY (id_meja) REFERENCES meja (id_meja)
      )
    ''');

    batch.execute('''
      CREATE TABLE transaksi_detail (
        id_detail INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER NOT NULL,
        id_produk INTEGER NOT NULL,
        qty INTEGER NOT NULL DEFAULT 1,
        harga REAL NOT NULL DEFAULT 0,
        subtotal REAL NOT NULL DEFAULT 0,
        catatan TEXT,
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id_transaksi),
        FOREIGN KEY (id_produk) REFERENCES produk (id_produk)
      )
    ''');

    batch.execute('''
      CREATE TABLE pembayaran (
        id_pembayaran INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER NOT NULL,
        id_metode INTEGER NOT NULL,
        total_bayar REAL NOT NULL DEFAULT 0,
        uang_diterima REAL NOT NULL DEFAULT 0,
        kembalian REAL NOT NULL DEFAULT 0,
        waktu_bayar TEXT,
        status TEXT NOT NULL DEFAULT 'paid',
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id_transaksi),
        FOREIGN KEY (id_metode) REFERENCES metode_pembayaran (id_metode)
      )
    ''');

    batch.execute('''
      CREATE TABLE pengeluaran (
        id_pengeluaran INTEGER PRIMARY KEY AUTOINCREMENT,
        id_shift INTEGER NOT NULL,
        kategori TEXT NOT NULL,
        nominal REAL NOT NULL DEFAULT 0,
        keterangan TEXT,
        tanggal TEXT NOT NULL,
        FOREIGN KEY (id_shift) REFERENCES shift (id_shift)
      )
    ''');

    batch.execute('''
      CREATE TABLE closing (
        id_closing INTEGER PRIMARY KEY AUTOINCREMENT,
        id_shift INTEGER NOT NULL,
        total_penjualan REAL NOT NULL DEFAULT 0,
        total_cash REAL NOT NULL DEFAULT 0,
        total_qris REAL NOT NULL DEFAULT 0,
        total_pengeluaran REAL NOT NULL DEFAULT 0,
        saldo_akhir REAL NOT NULL DEFAULT 0,
        waktu_closing TEXT,
        status TEXT NOT NULL DEFAULT 'closed',
        FOREIGN KEY (id_shift) REFERENCES shift (id_shift)
      )
    ''');

    await batch.commit(noResult: true);
    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();

    batch.insert('roles', {'id_role': 1, 'nama_role': 'Admin', 'deskripsi': 'Pemilik / Manajer'});
    batch.insert('roles', {'id_role': 2, 'nama_role': 'Kasir', 'deskripsi': 'Kasir toko'});

    // Default credentials kept identical to the pre-existing local seed
    // (admin/admin, kasir/kasir) so nothing else in the app (docs, demo
    // hints on the login page) needs to change.
    batch.insert('users', {
      'id_user': 1,
      'id_role': 1,
      'nama': 'Admin Sushimoo',
      'username': 'admin',
      'password': 'admin',
      'status': 1,
    });
    batch.insert('users', {
      'id_user': 2,
      'id_role': 2,
      'nama': 'Kasir Sushimoo',
      'username': 'kasir',
      'password': 'kasir',
      'status': 1,
    });

    batch.insert('metode_pembayaran', {'id_metode': 1, 'nama_metode': 'Cash', 'status': 1});
    batch.insert('metode_pembayaran', {'id_metode': 2, 'nama_metode': 'QRIS', 'status': 1});
    batch.insert('metode_pembayaran', {'id_metode': 3, 'nama_metode': 'Debit', 'status': 1});

    final categories = [
      {'id_kategori': 1, 'nama_kategori': 'Sushi', 'deskripsi': 'Menu sushi utama', 'status': 1},
      {'id_kategori': 2, 'nama_kategori': 'Ramen', 'deskripsi': 'Menu ramen & mie', 'status': 1},
      {'id_kategori': 3, 'nama_kategori': 'Minuman', 'deskripsi': 'Minuman dingin & panas', 'status': 1},
      {'id_kategori': 4, 'nama_kategori': 'Dessert', 'deskripsi': 'Menu penutup', 'status': 1},
    ];
    for (final c in categories) {
      batch.insert('kategori', c);
    }

    final products = [
      {'id_produk': 1, 'id_kategori': 1, 'nama_produk': 'Salmon Sushi', 'harga': 35000.0, 'status': 1},
      {'id_produk': 2, 'id_kategori': 1, 'nama_produk': 'Tuna Sushi', 'harga': 32000.0, 'status': 1},
      {'id_produk': 3, 'id_kategori': 1, 'nama_produk': 'California Roll', 'harga': 38000.0, 'status': 1},
      {'id_produk': 4, 'id_kategori': 2, 'nama_produk': 'Ramen Original', 'harga': 45000.0, 'status': 1},
      {'id_produk': 5, 'id_kategori': 2, 'nama_produk': 'Ramen Pedas', 'harga': 48000.0, 'status': 1},
      {'id_produk': 6, 'id_kategori': 3, 'nama_produk': 'Green Tea', 'harga': 12000.0, 'status': 1},
      {'id_produk': 7, 'id_kategori': 3, 'nama_produk': 'Orange Juice', 'harga': 15000.0, 'status': 1},
      {'id_produk': 8, 'id_kategori': 4, 'nama_produk': 'Mochi', 'harga': 18000.0, 'status': 1},
    ];
    for (final p in products) {
      batch.insert('produk', p);
    }

    final ingredients = [
      {'id_bahan': 1, 'nama_bahan': 'Nasi', 'satuan': 'gram', 'minimal_stok': 2000.0},
      {'id_bahan': 2, 'nama_bahan': 'Salmon', 'satuan': 'gram', 'minimal_stok': 1000.0},
      {'id_bahan': 3, 'nama_bahan': 'Tuna', 'satuan': 'gram', 'minimal_stok': 1000.0},
      {'id_bahan': 4, 'nama_bahan': 'Nori', 'satuan': 'lembar', 'minimal_stok': 50.0},
      {'id_bahan': 5, 'nama_bahan': 'Mie Ramen', 'satuan': 'pcs', 'minimal_stok': 30.0},
    ];
    for (final i in ingredients) {
      batch.insert('bahan_baku', i);
    }

    final stock = [
      {'id_stok': 1, 'id_bahan': 1, 'jumlah': 10000.0},
      {'id_stok': 2, 'id_bahan': 2, 'jumlah': 5000.0},
      {'id_stok': 3, 'id_bahan': 3, 'jumlah': 5000.0},
      {'id_stok': 4, 'id_bahan': 4, 'jumlah': 200.0},
      {'id_stok': 5, 'id_bahan': 5, 'jumlah': 100.0},
    ];
    for (final s in stock) {
      batch.insert('stok_bahan', s);
    }

    final tables = List.generate(
      8,
      (i) => {
        'id_meja': i + 1,
        'nomor_meja': '${i + 1}',
        'kapasitas': 4,
        'status': 'available',
      },
    );
    for (final t in tables) {
      batch.insert('meja', t);
    }

    await batch.commit(noResult: true);
  }

  // ---- Low-level helpers used by the repositories --------------------

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// Wipes and re-seeds the whole database. Exposed for a future
  /// "Reset demo data" setting; not wired to any UI yet.
  Future<void> resetAndReseed() async {
    final db = await database;
    await db.close();
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    await deleteDatabase(path);
    _db = null;
    await database;
  }
}

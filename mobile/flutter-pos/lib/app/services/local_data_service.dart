import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/table.dart';

class LocalUser {
  final int? id;
  final String username;
  final String name;
  final String role;
  final String token;

  LocalUser({
    this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.token,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'username': username,
        'name': name,
        'role': role,
        'token': token,
      };

  factory LocalUser.fromRow(Map<String, dynamic> row) => LocalUser(
        id: row['id'] as int,
        username: row['username'] as String,
        name: row['name'] as String,
        role: row['role'] as String,
        token: row['token'] as String,
      );
}

class LocalCategory {
  final int? id;
  final String name;
  final String? description;

  LocalCategory({this.id, required this.name, this.description});

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'name': name,
        'description': description,
      };

  factory LocalCategory.fromRow(Map<String, dynamic> row) => LocalCategory(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String?,
      );
}

class LocalProduct {
  final int? id;
  final int categoryId;
  final String name;
  final int price;
  final String? imageUrl;
  final bool isAvailable;

  LocalProduct({
    this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'category_id': categoryId,
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'is_available': isAvailable ? 1 : 0,
      };

  factory LocalProduct.fromRow(Map<String, dynamic> row) => LocalProduct(
        id: row['id'] as int,
        categoryId: row['category_id'] as int,
        name: row['name'] as String,
        price: row['price'] as int,
        imageUrl: row['image_url'] as String?,
        isAvailable: (row['is_available'] as int) == 1,
      );
}

class LocalTable {
  final int? id;
  final String name;
  final int capacity;
  final bool isOccupied;

  LocalTable({
    this.id,
    required this.name,
    this.capacity = 4,
    this.isOccupied = false,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'name': name,
        'capacity': capacity,
        'is_occupied': isOccupied ? 1 : 0,
      };

  factory LocalTable.fromRow(Map<String, dynamic> row) => LocalTable(
        id: row['id'] as int,
        name: row['name'] as String,
        capacity: row['capacity'] as int? ?? 4,
        isOccupied: (row['is_occupied'] as int) == 1,
      );
}

class LocalTransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final String productName;
  final int quantity;
  final int price;

  LocalTransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'transaction_id': transactionId,
        'product_id': productId,
        'product_name': productName,
        'quantity': quantity,
        'price': price,
      };

  factory LocalTransactionItem.fromRow(Map<String, dynamic> row) =>
      LocalTransactionItem(
        id: row['id'] as int,
        transactionId: row['transaction_id'] as int,
        productId: row['product_id'] as int,
        productName: row['product_name'] as String,
        quantity: row['quantity'] as int,
        price: row['price'] as int,
      );
}

class LocalTransaction {
  final int? id;
  final int tableId;
  final String tableName;
  final int total;
  final String status;
  final String createdAt;
  final String? paymentMethod;
  final List<LocalTransactionItem> items;

  LocalTransaction({
    this.id,
    required this.tableId,
    required this.tableName,
    required this.total,
    this.status = 'pending',
    required this.createdAt,
    this.paymentMethod,
    required this.items,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'table_id': tableId,
        'table_name': tableName,
        'total': total,
        'status': status,
        'created_at': createdAt,
        'payment_method': paymentMethod,
      };

  factory LocalTransaction.fromRow(Map<String, dynamic> row) =>
      LocalTransaction(
        id: row['id'] as int,
        tableId: row['table_id'] as int,
        tableName: row['table_name'] as String,
        total: row['total'] as int,
        status: row['status'] as String? ?? 'pending',
        createdAt: row['created_at'] as String,
        paymentMethod: row['payment_method'] as String?,
        items: const [],
      );
}

class LocalDataService extends GetxService {
  static LocalDataService get to => Get.find<LocalDataService>();

  static const _dbName = 'sushimoo_local.db';
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            token TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            price INTEGER NOT NULL,
            image_url TEXT,
            is_available INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            capacity INTEGER NOT NULL DEFAULT 4,
            is_occupied INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_id INTEGER NOT NULL,
            table_name TEXT NOT NULL,
            total INTEGER NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            created_at TEXT NOT NULL,
            payment_method TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE transaction_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            transaction_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            product_name TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price INTEGER NOT NULL
          )
        ''');
        await _seed(db);
      },
    );
  }

  Future<void> _seed(Database db) async {
    await db.insert('users', LocalUser(
      username: 'admin',
      name: 'Admin Sushimoo',
      role: 'Admin',
      token: 'local-token-admin',
    ).toRow());

    final categories = [
      LocalCategory(name: 'Makanan', description: 'Menu makanan utama'),
      LocalCategory(name: 'Minuman', description: 'Menu minuman'),
      LocalCategory(name: 'Dessert', description: 'Menu penutup'),
    ];
    for (final c in categories) {
      await db.insert('categories', c.toRow());
    }

    final products = [
      LocalProduct(categoryId: 1, name: 'Salmon Sushi', price: 35000),
      LocalProduct(categoryId: 1, name: 'Tuna Sushi', price: 32000),
      LocalProduct(categoryId: 1, name: 'Ramen', price: 45000),
      LocalProduct(categoryId: 2, name: 'Green Tea', price: 12000),
      LocalProduct(categoryId: 2, name: 'Orange Juice', price: 15000),
      LocalProduct(categoryId: 3, name: 'Mochi', price: 18000),
    ];
    for (final p in products) {
      await db.insert('products', p.toRow());
    }

    final tables = List.generate(5, (i) => LocalTable(name: 'Meja ${i + 1}'));
    for (final t in tables) {
      await db.insert('tables', t.toRow());
    }
  }

  Future<LocalUser?> login(String username, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND name = ?',
      whereArgs: [username, password],
    );
    if (rows.isEmpty) return null;
    return LocalUser.fromRow(rows.first);
  }

  Future<List<LocalCategory>> getCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map(LocalCategory.fromRow).toList();
  }

  Future<List<LocalProduct>> getProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(LocalProduct.fromRow).toList();
  }

  Future<List<LocalTable>> getTables() async {
    final db = await database;
    final rows = await db.query('tables', orderBy: 'name ASC');
    return rows.map(LocalTable.fromRow).toList();
  }

  Future<List<Category>> getAppCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map((row) => Category(
      idKategori: row['id'] as int,
      namaKategori: row['name'] as String,
      deskripsi: row['description'] as String?,
      status: true,
    )).toList();
  }

  Future<List<Product>> getAppProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map((row) => Product(
      idProduk: row['id'] as int,
      idKategori: row['category_id'] as int,
      namaProduk: row['name'] as String,
      harga: (row['price'] as int).toDouble(),
      gambar: row['image_url'] as String?,
      status: (row['is_available'] as int) == 1,
      category: null,
      recipes: null,
    )).toList();
  }

  Future<List<TableModel>> getAppTables() async {
    final db = await database;
    final rows = await db.query('tables', orderBy: 'name ASC');
    return rows.map((row) => TableModel(
      idMeja: row['id'] as int,
      nomorMeja: row['name'] as String,
      kapasitas: row['capacity'] as int? ?? 4,
      status: (row['is_occupied'] as int) == 1 ? 'occupied' : 'available',
    )).toList();
  }

  Future<int> createTransaction(LocalTransaction tx) async {
    final db = await database;
    final id = await db.insert('transactions', tx.toRow());
    for (final item in tx.items) {
      await db.insert('transaction_items', item.toRow());
    }
    return id;
  }

  Future<List<LocalTransaction>> getTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'created_at DESC');
    return rows.map(LocalTransaction.fromRow).toList();
  }
}

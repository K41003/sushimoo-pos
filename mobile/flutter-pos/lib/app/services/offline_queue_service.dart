import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Status of a queued order.
enum QueuedOrderStatus { pending, syncing, failed }

/// A single offline-queued `placeOrder` payload.
///
/// Mirrors exactly what `PosController.placeOrder()` sends to
/// `POST /transaksi` today (`id_meja` + `items`), plus bookkeeping
/// fields needed to show it in a "pending sync" list and retry it later.
class QueuedOrder {
  final int? id; // sqflite rowid, null until inserted
  final int? idMeja;
  final String itemsJson; // encoded `cart.map((e) => e.toPayload())`
  final String createdAt; // ISO8601, for display/ordering
  final QueuedOrderStatus status;
  final int retryCount;
  final String? lastError;

  const QueuedOrder({
    this.id,
    this.idMeja,
    required this.itemsJson,
    required this.createdAt,
    this.status = QueuedOrderStatus.pending,
    this.retryCount = 0,
    this.lastError,
  });

  Map<String, dynamic> get body => {
        if (idMeja != null) 'id_meja': idMeja,
        'items': jsonDecode(itemsJson),
      };

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'id_meja': idMeja,
        'items_json': itemsJson,
        'created_at': createdAt,
        'status': status.name,
        'retry_count': retryCount,
        'last_error': lastError,
      };

  factory QueuedOrder.fromRow(Map<String, dynamic> row) => QueuedOrder(
        id: row['id'] as int,
        idMeja: row['id_meja'] as int?,
        itemsJson: row['items_json'] as String,
        createdAt: row['created_at'] as String,
        status: QueuedOrderStatus.values.firstWhere(
          (s) => s.name == row['status'],
          orElse: () => QueuedOrderStatus.pending,
        ),
        retryCount: row['retry_count'] as int? ?? 0,
        lastError: row['last_error'] as String?,
      );

  QueuedOrder copyWith({
    int? id,
    QueuedOrderStatus? status,
    int? retryCount,
    String? lastError,
  }) =>
      QueuedOrder(
        id: id ?? this.id,
        idMeja: idMeja,
        itemsJson: itemsJson,
        createdAt: createdAt,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError ?? this.lastError,
      );
}

/// Local sqflite-backed queue for orders that couldn't be sent to
/// `POST /transaksi` (e.g. no network at the table). Kept deliberately
/// narrow in scope: it only stores what `PosController.placeOrder()`
/// needs to resend, not printing/payment (those still happen only
/// after a successful send, same as the online path today).
///
/// `pendingCount` is reactive so a small badge/button ("Sync Now (n)")
/// can be shown anywhere in the app without polling.
class OfflineQueueService extends GetxService {
  static OfflineQueueService get to => Get.find<OfflineQueueService>();

  static const _dbName = 'sushimoo_offline_queue.db';
  static const _table = 'queued_orders';

  Database? _db;
  final pendingCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    await _open();
    await _refreshPendingCount();
  }

  Future<void> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_meja INTEGER,
            items_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            retry_count INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
          )
        ''');
      },
    );
  }

  Future<Database> get _database async {
    if (_db == null) await _open();
    return _db!;
  }

  /// Persists a failed/offline order. Called from `PosController.placeOrder()`
  /// when the `/transaksi` POST couldn't reach the server.
  Future<QueuedOrder> enqueue({
    int? idMeja,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await _database;
    final order = QueuedOrder(
      idMeja: idMeja,
      itemsJson: jsonEncode(items),
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await db.insert(_table, order.toRow());
    await _refreshPendingCount();
    return order.copyWith(id: id);
  }

  /// All orders still needing sync (pending or previously failed).
  /// `syncing` rows are excluded so two overlapping sync runs don't
  /// double-send the same order.
  Future<List<QueuedOrder>> pending() async {
    final db = await _database;
    await db.update(
      _table,
      {
        'status': QueuedOrderStatus.failed.name,
        'last_error': 'Sinkronisasi sebelumnya terputus',
      },
      where: 'status = ?',
      whereArgs: [QueuedOrderStatus.syncing.name],
    );

    final rows = await db.query(
      _table,
      where: 'status IN (?, ?)',
      whereArgs: [QueuedOrderStatus.pending.name, QueuedOrderStatus.failed.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(QueuedOrder.fromRow).toList();
  }

  Future<void> markSyncing(int id) async {
    final db = await _database;
    await db.update(_table, {'status': QueuedOrderStatus.syncing.name},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markFailed(int id, String error) async {
    final db = await _database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    final current = rows.isNotEmpty ? QueuedOrder.fromRow(rows.first) : null;
    await db.update(
      _table,
      {
        'status': QueuedOrderStatus.failed.name,
        'retry_count': (current?.retryCount ?? 0) + 1,
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await _refreshPendingCount();
  }

  /// Removes an order once it has been successfully sent.
  Future<void> remove(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    await _refreshPendingCount();
  }

  Future<void> _refreshPendingCount() async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM $_table WHERE status IN (?, ?)',
      [QueuedOrderStatus.pending.name, QueuedOrderStatus.failed.name],
    );
    pendingCount.value = Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> count() async {
    await _refreshPendingCount();
    return pendingCount.value;
  }
}

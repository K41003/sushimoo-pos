import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'printer_service.dart';
import '../../data/models/transaction.dart';

/// What kind of ticket a queued print job represents. Only the two jobs
/// `PrinterService` already knows how to render are supported — this
/// queue doesn't invent new ticket formats, it just makes the existing
/// ones retryable.
enum PrintJobType { kitchen, customerReceipt }

class QueuedPrintJob {
  final int? id;
  final PrintJobType type;
  final String transactionJson; // encoded Transaction.toJson()-shaped map
  final String createdAt;
  final int retryCount;
  final String? lastError;

  const QueuedPrintJob({
    this.id,
    required this.type,
    required this.transactionJson,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'type': type.name,
        'transaction_json': transactionJson,
        'created_at': createdAt,
        'retry_count': retryCount,
        'last_error': lastError,
      };

  factory QueuedPrintJob.fromRow(Map<String, dynamic> row) => QueuedPrintJob(
        id: row['id'] as int,
        type: PrintJobType.values.firstWhere((t) => t.name == row['type']),
        transactionJson: row['transaction_json'] as String,
        createdAt: row['created_at'] as String,
        retryCount: row['retry_count'] as int? ?? 0,
        lastError: row['last_error'] as String?,
      );
}

/// Handles print reliability for kitchen tickets / customer receipts.
///
/// PROBLEM THIS FIXES: `PrinterService._printLines()` (printer_service.dart)
/// silently no-ops when `isConnected.value` is false — a Bluetooth
/// thermal printer disconnecting mid-shift (common: out of range, low
/// battery, paper jam causing a reset) used to mean a kitchen ticket
/// just vanished with no signal to the cashier that anything went wrong.
///
/// Behavior now:
///  1. `printKitchenTicket` / `printCustomerReceipt` are attempted with a
///     few quick automatic retries (short delay between attempts, in
///     case the disconnect is momentary).
///  2. If all retries fail, the job is persisted to a local sqflite
///     queue instead of being dropped — `pendingCount` goes up, and a
///     "Print Queue (n)" indicator (see `PrintQueueButton`) becomes
///     visible so the cashier knows physical tickets are missing.
///  3. Once the printer reconnects (see `SettingController.connectPrinter`)
///     or on manual "Retry" tap, `retryAll()` drains the queue.
///
/// Scope is deliberately narrow: this only wraps the two ticket types
/// `PrinterService` already supports. It does not touch the PDF closing
/// report (`printClosingReport`), which already goes through the OS
/// print dialog and has its own success/failure surface.
class PrintQueueService extends GetxService {
  static PrintQueueService get to => Get.find<PrintQueueService>();

  static const _dbName = 'sushimoo_print_queue.db';
  static const _table = 'queued_prints';
  static const _maxAutoRetries = 3;
  static const _retryDelay = Duration(milliseconds: 800);

  Database? _db;
  final pendingCount = 0.obs;
  final isRetrying = false.obs;

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
            type TEXT NOT NULL,
            transaction_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
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

  /// Attempts to print a kitchen ticket, retrying a few times before
  /// falling back to the persistent queue. Call sites that used to call
  /// `PrinterService.to.printKitchenTicket(trx)` directly should call
  /// this instead — signature/behavior is a superset (same happy path,
  /// added resilience on failure).
  Future<void> printKitchenTicket(Transaction trx) => _attempt(
        type: PrintJobType.kitchen,
        transaction: trx,
        action: () => PrinterService.to.printKitchenTicket(trx),
      );

  Future<void> printCustomerReceipt(Transaction trx) => _attempt(
        type: PrintJobType.customerReceipt,
        transaction: trx,
        action: () => PrinterService.to.printCustomerReceipt(trx),
      );

  Future<void> _attempt({
    required PrintJobType type,
    required Transaction transaction,
    required Future<void> Function() action,
  }) async {
    for (var i = 0; i < _maxAutoRetries; i++) {
      try {
        if (!PrinterService.to.isConnected.value) {
          throw StateError('Printer not connected');
        }
        await action();
        return; // success, nothing to queue
      } catch (_) {
        if (i < _maxAutoRetries - 1) {
          await Future.delayed(_retryDelay);
        }
      }
    }

    // All auto-retries exhausted — persist for manual/later retry rather
    // than silently dropping the ticket.
    await _enqueue(type: type, transaction: transaction, error: 'Printer unreachable after $_maxAutoRetries attempts');
  }

  Future<void> _enqueue({
    required PrintJobType type,
    required Transaction transaction,
    required String error,
  }) async {
    final db = await _database;
    await db.insert(_table, {
      'type': type.name,
      'transaction_json': jsonEncode(_transactionToRetryPayload(transaction)),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
      'last_error': error,
    });
    await _refreshPendingCount();
  }

  /// Minimal fields needed to re-render either ticket type. Kept as its
  /// own small map (rather than assuming `Transaction.toJson()` round
  /// trips every nested relation) since `Transaction` doesn't currently
  /// define `toJson()` — only `fromJson()` — and printing only reads a
  /// handful of fields (see `PrinterService.printKitchenTicket` /
  /// `printCustomerReceipt`).
  Map<String, dynamic> _transactionToRetryPayload(Transaction trx) => {
        'id_transaksi': trx.idTransaksi,
        'invoice_number': trx.invoiceNumber,
        'id_shift': trx.idShift,
        'id_user': trx.idUser,
        'id_meja': trx.idMeja,
        'tanggal': trx.tanggal,
        'total': trx.total,
        'status': trx.status,
        // `TableModel.toJson()` exists (see data/models/table.dart) and
        // is used as-is. `Product` has no `toJson()` in this codebase
        // (see data/models/product.dart — fromJson only), so only the
        // fields printer_service.dart actually reads (`namaProduk`) are
        // captured manually rather than adding a new serializer to a
        // model this feature doesn't otherwise need to touch.
        'table': trx.table != null ? trx.table!.toJson() : null,
        'details': trx.details
            ?.map((d) => {
                  'id_detail': d.idDetail,
                  'id_transaksi': d.idTransaksi,
                  'id_produk': d.idProduk,
                  'qty': d.qty,
                  'harga': d.harga,
                  'subtotal': d.subtotal,
                  'catatan': d.catatan,
                  'product': d.product != null
                      ? {
                          'id_produk': d.product!.idProduk,
                          'id_kategori': d.product!.idKategori,
                          'nama_produk': d.product!.namaProduk,
                          'harga': d.product!.harga,
                          'gambar': d.product!.gambar,
                          'status': d.product!.status ? 1 : 0,
                        }
                      : null,
                })
            .toList(),
        'payment': trx.payment != null
            ? {
                'id_pembayaran': trx.payment!.idPembayaran,
                'id_transaksi': trx.payment!.idTransaksi,
                'id_metode': trx.payment!.idMetode,
                'total_bayar': trx.payment!.totalBayar,
                'uang_diterima': trx.payment!.uangDiterima,
                'kembalian': trx.payment!.kembalian,
                'waktu_bayar': trx.payment!.waktuBayar,
                'status': trx.payment!.status,
              }
            : null,
      };

  /// Retries every queued print job once (e.g. after the cashier
  /// reconnects the printer or taps "Retry" on the print queue button).
  /// Jobs that fail again stay in the queue with an updated retry count;
  /// jobs that succeed are removed.
  Future<void> retryAll() async {
    if (isRetrying.value) return;
    isRetrying.value = true;

    final db = await _database;
    final rows = await db.query(_table, orderBy: 'created_at ASC');
    final jobs = rows.map(QueuedPrintJob.fromRow).toList();

    for (final job in jobs) {
      if (job.id == null) continue;
      final trx = _transactionFromRetryPayload(
          jsonDecode(job.transactionJson) as Map<String, dynamic>);

      bool success;
      try {
        if (!PrinterService.to.isConnected.value) {
          throw StateError('Printer not connected');
        }
        if (job.type == PrintJobType.kitchen) {
          await PrinterService.to.printKitchenTicket(trx);
        } else {
          await PrinterService.to.printCustomerReceipt(trx);
        }
        success = true;
      } catch (_) {
        success = false;
      }

      if (success) {
        await db.delete(_table, where: 'id = ?', whereArgs: [job.id]);
      } else {
        await db.update(
          _table,
          {'retry_count': job.retryCount + 1, 'last_error': 'Retry failed'},
          where: 'id = ?',
          whereArgs: [job.id],
        );
      }
    }

    isRetrying.value = false;
    await _refreshPendingCount();
  }

  /// Rebuilds just enough of a [Transaction] to satisfy
  /// `PrinterService.printKitchenTicket`/`printCustomerReceipt`, which
  /// only read `invoiceNumber`, `table`, `tanggal`, `details`, `total`,
  /// and `payment` — see printer_service.dart.
  Transaction _transactionFromRetryPayload(Map<String, dynamic> json) =>
      Transaction.fromJson(json);

  Future<void> _refreshPendingCount() async {
    final db = await _database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM $_table');
    pendingCount.value = Sqflite.firstIntValue(result) ?? 0;
  }
}

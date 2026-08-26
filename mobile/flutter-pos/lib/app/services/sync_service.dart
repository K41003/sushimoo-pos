import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'api_client.dart';
import 'offline_queue_service.dart';
import 'print_queue_service.dart';
import '../../data/models/transaction.dart';

/// Result of one sync pass, so the UI (Sync Now button, splash, etc.)
/// can show a meaningful summary instead of a generic "done".
class SyncResult {
  final int succeeded;
  final int failed;
  const SyncResult({required this.succeeded, required this.failed});

  int get total => succeeded + failed;
  bool get hadWork => total > 0;
}

/// Drains [OfflineQueueService] against the real `/transaksi` endpoint.
///
/// Scope is intentionally limited to orders (`placeOrder`) — the same
/// scope the queue itself stores. Each order is sent one at a time (not
/// in parallel) so table/seat ordering at the counter stays predictable
/// and so a mid-run network drop doesn't leave a batch half-applied in
/// a hard-to-reason-about interleaving.
///
/// `isSyncing` is exposed as an Rx so a button can disable itself /
/// show a spinner while a sync run is in flight, and so `SplashController`
/// / app-resume hooks don't kick off a second overlapping run.
class SyncService extends GetxService {
  static SyncService get to => Get.find<SyncService>();

  final ApiClient _api = ApiClient.to;
  final isSyncing = false.obs;

  /// Runs one sync pass over all pending/failed queued orders.
  ///
  /// Safe to call opportunistically (app resume, splash, pull-to-refresh)
  /// — it's a no-op if a run is already in progress or the queue is empty.
  Future<SyncResult> syncNow({bool showToast = true}) async {
    if (isSyncing.value) {
      return const SyncResult(succeeded: 0, failed: 0);
    }

    final queue = OfflineQueueService.to;
    final orders = await queue.pending();
    if (orders.isEmpty) {
      return const SyncResult(succeeded: 0, failed: 0);
    }

    isSyncing.value = true;
    if (showToast) EasyLoading.show(status: 'Syncing ${orders.length} order(s)...');

    var succeeded = 0;
    var failed = 0;

    for (final order in orders) {
      if (order.id == null) continue;
      await queue.markSyncing(order.id!);

      final res = await _api.post(
        '/transaksi',
        body: order.body,
        fromData: (d) => Transaction.fromJson(d as Map<String, dynamic>),
      );

      if (res.success && res.data != null) {
        succeeded++;
        await queue.remove(order.id!);
        // Best-effort kitchen ticket for the now-synced order. Printing
        // is non-fatal here — the order itself is already safely on the
        // server, which is the part that actually matters if this fails.
        try {
          await PrintQueueService.to.printKitchenTicket(res.data as Transaction);
        } catch (_) {}
      } else {
        failed++;
        await queue.markFailed(order.id!, res.message);
      }
    }

    isSyncing.value = false;
    if (showToast) {
      EasyLoading.dismiss();
      if (failed == 0) {
        EasyLoading.showSuccess('$succeeded order(s) synced');
      } else {
        EasyLoading.showError('$succeeded synced, $failed still pending');
      }
    }

    return SyncResult(succeeded: succeeded, failed: failed);
  }
}

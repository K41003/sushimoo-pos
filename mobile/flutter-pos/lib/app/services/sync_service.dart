import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'api_client.dart';
import 'offline_queue_service.dart';
import 'print_queue_service.dart';
import '../../app/constants/app_constants.dart';
import '../../data/models/transaction.dart';

/// Result of one sync pass, so the UI can show a meaningful summary.
class SyncResult {
  final int succeeded;
  final int failed;
  const SyncResult({required this.succeeded, required this.failed});

  int get total => succeeded + failed;
  bool get hadWork => total > 0;
}

/// Drains [OfflineQueueService] against the real `/transaksi` endpoint.
///
/// Each order is sent one at a time. If a request, JSON parse, print attempt,
/// or local DB operation throws, the row is moved back to `failed` so it can be
/// retried instead of being stranded forever as `syncing`.
class SyncService extends GetxService {
  static SyncService get to => Get.find<SyncService>();

  final ApiClient _api = ApiClient.to;
  final isSyncing = false.obs;

  Future<SyncResult> syncNow({bool showToast = true}) async {
    if (AppConstants.localMode) {
      return const SyncResult(succeeded: 0, failed: 0);
    }

    if (isSyncing.value) {
      return const SyncResult(succeeded: 0, failed: 0);
    }

    final queue = OfflineQueueService.to;
    final orders = await queue.pending();
    if (orders.isEmpty) {
      return const SyncResult(succeeded: 0, failed: 0);
    }

    isSyncing.value = true;
    if (showToast) {
      EasyLoading.show(status: 'Syncing ${orders.length} order(s)...');
    }

    var succeeded = 0;
    var failed = 0;

    try {
      for (final order in orders) {
        final id = order.id;
        if (id == null) continue;

        await queue.markSyncing(id);

        try {
          final res = await _api.post(
            '/transaksi',
            body: order.body,
            fromData: (d) => Transaction.fromJson(d as Map<String, dynamic>),
          );

          if (res.success && res.data != null) {
            succeeded++;
            await queue.remove(id);
            try {
              await PrintQueueService.to
                  .printKitchenTicket(res.data as Transaction);
            } catch (_) {}
          } else {
            failed++;
            await queue.markFailed(id, res.message);
          }
        } catch (e) {
          failed++;
          await queue.markFailed(id, e.toString());
        }
      }

      return SyncResult(succeeded: succeeded, failed: failed);
    } finally {
      isSyncing.value = false;
      if (showToast) {
        EasyLoading.dismiss();
        if (failed == 0) {
          EasyLoading.showSuccess('$succeeded order(s) synced');
        } else {
          EasyLoading.showError('$succeeded synced, $failed still pending');
        }
      }
    }
  }
}

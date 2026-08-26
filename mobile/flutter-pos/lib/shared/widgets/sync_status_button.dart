import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/services/offline_queue_service.dart';
import '../../app/services/sync_service.dart';

/// Small pill button showing how many orders are waiting to sync, with
/// a manual "Sync Now" action. Meant to be dropped into `AppScaffold`'s
/// `actions` on the POS page (next to `AppGlassActionButton`).
///
/// Renders nothing when the queue is empty and no sync is in progress,
/// so it doesn't add visual noise on the common (online) path.
class SyncStatusButton extends StatelessWidget {
  const SyncStatusButton({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = OfflineQueueService.to;
    final sync = SyncService.to;

    return Obx(() {
      final pending = queue.pendingCount.value;
      final syncing = sync.isSyncing.value;

      if (pending == 0 && !syncing) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: syncing ? null : () => sync.syncNow(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (syncing)
                    SizedBox(
                      width: 14.r,
                      height: 14.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.warning),
                    )
                  else
                    Icon(Icons.cloud_off_rounded, size: 16.sp, color: AppColors.warning),
                  SizedBox(width: 6.w),
                  Text(
                    syncing ? 'Syncing...' : 'Sync Now ($pending)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

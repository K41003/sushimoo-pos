import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/services/print_queue_service.dart';

/// Small pill button showing how many print jobs (kitchen tickets /
/// receipts) failed to print and are queued for retry, with a manual
/// "Retry" action. Mirrors `SyncStatusButton` (sync_status_button.dart)
/// visually and behaviorally so the two "something is queued locally"
/// indicators read as the same UI language, not two different systems.
///
/// Renders nothing when the queue is empty and no retry is in progress.
class PrintQueueButton extends StatelessWidget {
  const PrintQueueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = PrintQueueService.to;

    return Obx(() {
      final pending = queue.pendingCount.value;
      final retrying = queue.isRetrying.value;

      if (pending == 0 && !retrying) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: retrying ? null : () => queue.retryAll(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (retrying)
                    SizedBox(
                      width: 14.r,
                      height: 14.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.danger),
                    )
                  else
                    Icon(Icons.print_disabled_rounded, size: 16.sp, color: AppColors.danger),
                  SizedBox(width: 6.w),
                  Text(
                    retrying ? 'Mencoba ulang...' : 'Antrean Cetak ($pending)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
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

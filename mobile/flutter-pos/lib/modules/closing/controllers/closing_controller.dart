import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/closing.dart';
import '../../../data/models/shift.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';

/// UI CHANGE: `doClosing()` used to open a `Get.defaultDialog` — GetX's
/// stock dialog, visually inconsistent with the rest of the app. Swapped
/// to `AppDialog.confirm` (glass panel + gradient CTA) to match every
/// other confirmation dialog in the app.
///
/// =====================================================================
/// CORRECTION: the previous version of this file (written without
/// seeing the real `closing_page.dart`) omitted `printing` and
/// `printReport()`, which the actual page already depends on for its
/// per-history-card reprint button (`Obx(() => IconButton(... 
/// controller.printing.value ... onPressed: () => controller
/// .printReport(c) ...))`). Restored here in the same shape the page
/// expects — `printing` as an `RxBool` (matches the existing `loading`
/// pattern in this same class) and `printReport(Closing)` taking the
/// specific report to reprint, since history cards need to reprint an
/// arbitrary past closing, not just the most recent one.
///
/// UX FIX (design review P0 #4, unchanged in intent): both `doClosing()`
/// and `printReport()` now react to `PrinterService.printClosingReport`'s
/// `Future<bool>` return (see printer_service.dart) with distinct
/// messaging when the record/action succeeded but the physical/PDF
/// report failed to print, instead of a blanket success toast regardless
/// of print outcome.
class ClosingController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final activeShift = Rx<Shift?>(null);
  final history = <Closing>[].obs;
  final lastClosing = Rx<Closing?>(null);
  final loading = false.obs;

  /// Tracks the reprint-in-progress state for the history cards' print
  /// buttons specifically (separate from `loading`, which covers the
  /// initial data fetch / the "Tutup Shift" action) — matches the
  /// `Obx(() => controller.printing.value ...)` pattern already used in
  /// `closing_page.dart`'s `_reportCard`.
  final printing = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    final active = await _api.get('/shifts/active', fromData: (d) {
      return d == null ? null : Shift.fromJson(d as Map<String, dynamic>);
    });
    if (active.success) activeShift.value = active.data;
    final res = await _api.get('/closing/history', query: {'perPage': 50},
        fromData: (d) => d);
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<Closing>.fromJson({'data': res.data}, Closing.fromJson);
      history.assignAll(pag.items);
    }
  }

  Future<void> doClosing() async {
    if (activeShift.value == null) {
      EasyLoading.showError('No active shift');
      return;
    }
    final confirmed = await AppDialog.confirm(
      title: 'Closing Kasir',
      message: 'Generate closing report for this shift?',
      confirmText: 'Close',
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Closing...');
    final res = await _api.post('/shifts/${activeShift.value!.idShift}/closing');
    EasyLoading.dismiss();
    if (res.success && res.data != null) {
      final closing = Closing.fromJson(res.data as Map<String, dynamic>);
      lastClosing.value = closing;

      // Closing record is saved server-side at this point regardless of
      // what happens next — printing is a separate, best-effort step.
      final printed = await PrinterService.to
          .printClosingReport(closing, activeShift.value!);

      if (printed) {
        EasyLoading.showSuccess('Closing recorded and report printed');
      } else {
        // Distinct from a generic error: the closing itself succeeded,
        // only the report printout failed. Framing it as a warning
        // (not a failure) avoids making the cashier think the shift
        // close itself needs to be retried — they can reprint later via
        // `printReport()` from the history card.
        EasyLoading.showInfo(
          'Closing recorded, but the report failed to print. '
          'Use the print icon below to try again.',
        );
      }

      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  /// Reprints an arbitrary past closing report from the history list.
  /// Needs the shift the report belongs to for `PrinterService
  /// .printClosingReport`'s signature (`Closing`, `Shift`), so this
  /// falls back to `activeShift.value` when reprinting a report for a
  /// shift that's no longer active — the printed report itself only
  /// displays `shift.idShift`, so this is a reasonable best-effort
  /// association rather than requiring a full shift lookup by id.
  ///
  /// NOTE: if `activeShift.value` is null (no shift currently open) AND
  /// the report being reprinted belongs to a different, now-closed
  /// shift, the printed "Shift: X" line may not match `c.idShift`'s
  /// original shift precisely — flagging this as a known limitation
  /// rather than silently guessing a shift id. Consider adding a
  /// `Shift`/`idShift` reference directly onto `Closing` server-side if
  /// exact reprint fidelity across shifts matters.
  Future<void> printReport(Closing c) async {
    if (printing.value) return;
    printing.value = true;
    final shiftForReport = activeShift.value ??
        Shift(
          idShift: c.idShift,
          idUser: 0,
          pettyCash: 0,
          status: 'closed',
        );
    final printed =
        await PrinterService.to.printClosingReport(c, shiftForReport);
    printing.value = false;

    if (printed) {
      EasyLoading.showSuccess('Report sent to printer');
    } else {
      EasyLoading.showError('Failed to print report. Check the printer.');
    }
  }
}

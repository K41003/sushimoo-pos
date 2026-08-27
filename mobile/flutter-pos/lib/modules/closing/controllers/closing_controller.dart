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
/// BUG FIX: previously `doClosing()` required `activeShift.value != null`
/// and posted to `/shifts/{id}/closing`, but the Shift page's "Close
/// Shift" button (a completely separate action) already closed the
/// shift via `/shifts/{id}/close` — which used to ALSO silently generate
/// the closing report as a side effect. That meant by the time a cashier
/// navigated here, `activeShift` was already null, the "Closing Kasir"
/// button was disabled, and the report that had already been created was
/// unreachable (`/closing/history` was Admin-only server side too).
///
/// The backend now separates the two actions: `/shifts/{id}/close` only
/// closes the shift, and `/shifts/{id}/closing` (called here) both closes
/// the shift if needed AND generates the report, idempotently returning
/// the existing report if one was already generated for that shift. So
/// `doClosing()` can now be pressed either before or after "Close Shift"
/// was used, and each closed shift only ever gets a single Closing
/// record, matching what `history` will show.
class ClosingController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final activeShift = Rx<Shift?>(null);
  final history = <Closing>[].obs;
  final lastClosing = Rx<Closing?>(null);
  final loading = false.obs;
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
      if (lastClosing.value == null && pag.items.isNotEmpty) {
        // Surface the most recent report (e.g. one already generated via
        // the Shift page's "Close Shift" action) even if this session
        // never called doClosing() itself.
        lastClosing.value = pag.items.first;
      }
    } else if (!res.success) {
      EasyLoading.showError(res.message);
    }
  }

  /// Generates (or fetches, if already generated) the closing report for
  /// the given shift. `shiftId` defaults to the current active shift, but
  /// can also be used to (re)request a report for a shift that was
  /// already closed via the Shift page, since the endpoint is idempotent.
  Future<void> doClosing({int? shiftId}) async {
    final targetShiftId = shiftId ?? activeShift.value?.idShift;
    if (targetShiftId == null) {
      EasyLoading.showError('No shift to close.');
      return;
    }

    final confirmed = await AppDialog.confirm(
      title: 'Closing Kasir',
      message: 'Generate closing report for this shift?',
      confirmText: 'Close',
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Closing...');
    final res = await _api.post(
      '/shifts/$targetShiftId/closing',
      fromData: (d) => Closing.fromJson(d as Map<String, dynamic>),
    );
    EasyLoading.dismiss();
    if (res.success && res.data != null) {
      final closing = res.data as Closing;
      lastClosing.value = closing;
      await _printReport(closing);
      EasyLoading.showSuccess('Closing recorded');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  /// Re-prints any closing report from history (e.g. the cashier wants a
  /// second copy, or the report was generated on a different device).
  Future<void> printReport(Closing closing) async {
    await _printReport(closing);
  }

  Future<void> _printReport(Closing closing) async {
    if (printing.value) return;
    printing.value = true;
    try {
      final shift = activeShift.value?.idShift == closing.idShift
          ? activeShift.value
          : null;
      await PrinterService.to.printClosingReport(
        closing,
        shift ?? Shift(
          idShift: closing.idShift,
          idUser: 0,
          pettyCash: 0,
          status: 'closed',
        ),
      );
    } catch (_) {
      EasyLoading.showError('Failed to print closing report');
    } finally {
      printing.value = false;
    }
  }
}

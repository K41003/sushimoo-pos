import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/closing.dart';
import '../../../data/models/shift.dart';
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';

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
    if (AppConstants.localMode) {
      activeShift.value = null;
      history.clear();
      loading.value = false;
      return;
    }
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
        lastClosing.value = pag.items.first;
      }
    } else if (!res.success) {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> doClosing({int? shiftId}) async {
    if (AppConstants.localMode) {
      EasyLoading.showError('Not available in local mode');
      return;
    }
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

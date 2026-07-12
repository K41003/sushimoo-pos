import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/printer_service.dart';
import '../../../data/models/closing.dart';
import '../../../data/models/shift.dart';
import '../../../data/response/api_response.dart';

class ClosingController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final activeShift = Rx<Shift?>(null);
  final history = <Closing>[].obs;
  final lastClosing = Rx<Closing?>(null);
  final loading = false.obs;

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
    final confirmed = await Get.defaultDialog<bool>(
      title: 'Closing Kasir',
      middleText: 'Generate closing report for this shift?',
      textConfirm: 'Close',
      textCancel: 'Cancel',
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed != true) return;

    EasyLoading.show(status: 'Closing...');
    final res = await _api.post('/shifts/${activeShift.value!.idShift}/closing');
    EasyLoading.dismiss();
    if (res.success && res.data != null) {
      final closing = Closing.fromJson(res.data as Map<String, dynamic>);
      lastClosing.value = closing;
      await PrinterService.to.printClosingReport(closing, activeShift.value!);
      EasyLoading.showSuccess('Closing recorded');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

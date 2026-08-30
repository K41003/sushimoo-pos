import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';

class ReportController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final LocalDataService _local = LocalDataService.to;
  final loading = true.obs;
  final daily = RxMap();
  final last7 = RxMap();
  final monthly = RxMap();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      daily.value = await _local.getDailyReport();
      last7.value = await _local.getLast7DaysReport();
      monthly.value = await _local.getMonthlyReport();
      loading.value = false;
      return;
    }
    final d = await _api.get('/reports/daily', fromData: (x) => x);
    if (d.success && d.data != null) daily.value = d.data as Map;
    final l = await _api.get('/reports/last-7-days', fromData: (x) => x);
    if (l.success && l.data != null) last7.value = l.data as Map;
    final m = await _api.get('/reports/monthly', fromData: (x) => x);
    if (m.success && m.data != null) monthly.value = m.data as Map;
    loading.value = false;
    if (!d.success) EasyLoading.showError(d.message);
  }
}

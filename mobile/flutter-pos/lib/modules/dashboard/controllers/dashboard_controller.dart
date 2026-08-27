import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/auth_service.dart';
import '../../../app/services/local_data_service.dart';

class DashboardController extends GetxController {
  final ApiClient _api = ApiClient.to;
  final loading = true.obs;
  final isAdmin = false.obs;

  final RxMap adminData = RxMap();
  final RxMap cashierData = RxMap();

  @override
  void onInit() {
    super.onInit();
    isAdmin.value = AuthService.to.currentUser?.isAdmin ?? false;
    load();
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      final transactions = await LocalDataService.to.getTransactions();
      final totalOrders = transactions.length;
      final totalRevenue = transactions.fold<int>(0, (sum, t) => sum + t.total);
      final pendingOrders = transactions.where((t) => t.status == 'pending').length;
      final tables = await LocalDataService.to.getTables();
      final occupiedTables = tables.where((t) => t.isOccupied).length;

      final map = <String, dynamic>{
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'pending_orders': pendingOrders,
        'occupied_tables': occupiedTables,
        'available_tables': tables.length - occupiedTables,
        'recent_transactions': transactions.take(5).map((t) => {
              'id': t.id,
              'table_name': t.tableName,
              'total': t.total,
              'status': t.status,
              'created_at': t.createdAt,
            }).toList(),
      };

      if (isAdmin.value) {
        adminData.value = map;
      } else {
        cashierData.value = map;
      }
      loading.value = false;
      return;
    }
    final path = isAdmin.value ? '/dashboard/admin' : '/dashboard/cashier';
    final res = await _api.get(path, fromData: (d) => d);
    loading.value = false;
    if (res.success && res.data != null) {
      final map = res.data is Map ? res.data as Map : <String, dynamic>{};
      if (isAdmin.value) {
        adminData.value = map;
      } else {
        cashierData.value = map;
      }
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

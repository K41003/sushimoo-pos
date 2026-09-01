import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_constants.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/decorations.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/constants/strings.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/local_data_service.dart';
import '../../../data/models/table.dart' as tm;
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';

class TableController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
  final LocalDataService _local = LocalDataService.to;
  final items = <tm.TableModel>[].obs;
  final loading = false.obs;
  final RxString statusFilter = ''.obs;

  final statusOptions = const [
    'available',
    'occupied',
    'reserved',
    'cleaning',
  ];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    if (AppConstants.localMode) {
      final tables = await _local.getAppTables();
      final status = statusFilter.value;
      items.value = status.isEmpty
          ? tables
          : tables.where((t) => t.status == status).toList();
      loading.value = false;
      return;
    }
    final query = <String, dynamic>{'perPage': 100};
    if (statusFilter.value.isNotEmpty) {
      query['status'] = statusFilter.value;
    }
    final res = await _api.get(
      '/meja',
      query: query,
      fromData: (d) => d,
    );
    loading.value = false;
    if (res.success && res.data != null) {
      final pag = Paginated<tm.TableModel>.fromJson(
        {'data': res.data},
        tm.TableModel.fromJson,
      );
      items.value = pag.items;
    } else {
      EasyLoading.showError(res.message);
    }
  }

  void setStatusFilter(String value) {
    statusFilter.value = value;
    load();
  }

  Future<void> save(tm.TableModel? existing) async {
    final nomor = TextEditingController(text: existing?.nomorMeja ?? '');
    final kapasitas = TextEditingController(
      text: existing != null ? existing.kapasitas.toString() : '',
    );
    final status = (existing?.status ?? statusOptions.first).obs;
    final formKey = GlobalKey<FormState>();

    final result = await AppDialog.form<bool>(
      title: existing == null ? 'Tambah Meja' : 'Ubah Meja',
      icon: Icons.table_restaurant_rounded,
      maxWidth: 420.w,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nomor Meja',
              controller: nomor,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 14.h),
            AppTextField(
              label: 'Kapasitas',
              controller: kapasitas,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
            ),
            SizedBox(height: 14.h),
            Text(
              'Status Meja',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.inkMuted,
              ),
            ),
            SizedBox(height: 6.h),
            Obx(() => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration:
                      AppDecorations.control(radius: AppDimensions.radiusMd),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: status.value,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.inkMuted),
                      items: statusOptions
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  statusLabel(s),
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) status.value = v;
                      },
                    ),
                  ),
                )),
          ],
        ),
      ),
      onConfirm: () async {
        if (!formKey.currentState!.validate()) return false;
        return true;
      },
    );
    if (result != true) return;

    final body = {
      'nomor_meja': nomor.text.trim(),
      'kapasitas': int.tryParse(kapasitas.text) ?? 0,
      'status': status.value,
    };

    loading.value = true;
    EasyLoading.show(status: AppStrings.saving);
    if (AppConstants.localMode) {
      await _local.saveTable(
        id: existing?.idMeja,
        name: nomor.text.trim(),
        capacity: int.tryParse(kapasitas.text) ?? 0,
        status: status.value,
      );
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.saved);
      await load();
      return;
    }
    final res = existing == null
        ? await _api.post('/meja', body: body, fromData: (d) => d)
        : await _api.put('/meja/${existing.idMeja}',
            body: body, fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : AppStrings.saved);
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirm = await AppDialog.confirm(
      title: AppStrings.confirmDeleteTitle,
      message: 'Apakah kamu yakin ingin menghapus meja ini?',
      confirmText: AppStrings.delete,
      destructive: true,
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: AppStrings.deleting);
    if (AppConstants.localMode) {
      await _local.deleteTable(id);
      loading.value = false;
      EasyLoading.dismiss();
      EasyLoading.showSuccess(AppStrings.deleted);
      await load();
      return;
    }
    final res = await _api.delete('/meja/$id', fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(res.message.isNotEmpty ? res.message : AppStrings.deleted);
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

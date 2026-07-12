import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/services/api_client.dart';
import '../../../data/models/table.dart' as tm;
import '../../../data/response/api_response.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_text_field.dart';

class TableController extends GetxController {
  final ApiClient _api = Get.find<ApiClient>();
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

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(existing == null ? 'Add Table' : 'Edit Table'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Nomor Meja',
                controller: nomor,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              AppTextField(
                label: 'Kapasitas',
                controller: kapasitas,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12.h),
              Obx(() => InputDecorator(
                    decoration: const InputDecoration(labelText: 'Status'),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: status.value,
                      items: statusOptions
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) status.value = v;
                      },
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Save',
            onPressed: () {
              if (formKey.currentState!.validate()) Get.back(result: true);
            },
          ),
        ],
      ),
    );
    if (result != true) return;

    final body = {
      'nomor_meja': nomor.text.trim(),
      'kapasitas': int.tryParse(kapasitas.text) ?? 0,
      'status': status.value,
    };

    loading.value = true;
    EasyLoading.show(status: 'Saving...');
    final res = existing == null
        ? await _api.post('/meja', body: body, fromData: (d) => d)
        : await _api.put('/meja/${existing.idMeja}',
            body: body, fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(
          res.message.isNotEmpty ? res.message : 'Saved');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }

  Future<void> delete(int id) async {
    final confirm = await AppDialog.confirm(
      title: 'Delete Table',
      message: 'Are you sure you want to delete this table?',
    );
    if (confirm != true) return;

    loading.value = true;
    EasyLoading.show(status: 'Deleting...');
    final res = await _api.delete('/meja/$id', fromData: (d) => d);
    loading.value = false;
    EasyLoading.dismiss();

    if (res.success) {
      EasyLoading.showSuccess(
          res.message.isNotEmpty ? res.message : 'Deleted');
      await load();
    } else {
      EasyLoading.showError(res.message);
    }
  }
}

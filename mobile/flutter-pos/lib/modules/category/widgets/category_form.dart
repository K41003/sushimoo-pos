import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../data/models/category.dart';
import '../controllers/category_controller.dart';

/// REPLACES `category_form.dart` 1:1 — same class name `CategoryForm`,
/// same constructor (`controller`, `existing`).
class CategoryForm extends StatelessWidget {
  final CategoryController controller;
  final Category? existing;

  const CategoryForm({
    super.key,
    required this.controller,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nama Kategori',
            controller: controller.nameController,
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Deskripsi',
            controller: controller.descController,
            maxLines: 3,
          ),
          SizedBox(height: 16.h),
          Obx(() => Row(
                children: [
                  const Text('Active'),
                  const Spacer(),
                  Switch(
                    value: controller.selectedStatus.value,
                    onChanged: (v) => controller.selectedStatus.value = v,
                    activeColor: AppColors.salmon,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

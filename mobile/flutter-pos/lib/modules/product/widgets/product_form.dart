import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/decorations.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/product_controller.dart';
import '../../../data/models/product.dart';

/// REPLACES `product_form.dart` 1:1 — same class name `ProductForm`,
/// same constructor (`controller`, `existing`).
class ProductForm extends StatelessWidget {
  final ProductController controller;
  final Product? existing;

  const ProductForm({
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kategori',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted,
                ),
          ),
          SizedBox(height: 6.h),
          Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                decoration: AppDecorations.control(radius: AppDimensions.radiusMd),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedCategory.value,
                    isDense: false,
                    isExpanded: true,
                    hint: const Text('Pilih Kategori'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.inkMuted),
                    items: controller.categories
                        .map((c) => DropdownMenuItem<int>(
                              value: c.idKategori,
                              child: Text(c.namaKategori),
                            ))
                        .toList(),
                    onChanged: (v) => controller.selectedCategory.value = v,
                  ),
                ),
              )),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Nama Produk',
            controller: controller.nameController,
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Harga',
            controller: controller.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16.h),
          Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: AppDecorations.control(radius: AppDimensions.radiusMd),
                child: Row(
                  children: [
                    Text(
                      'Status Aktif',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Switch(
                      value: controller.selectedStatus.value,
                      onChanged: (v) => controller.selectedStatus.value = v,
                      activeColor: AppColors.salmon,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}


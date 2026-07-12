import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/product_controller.dart';
import '../../../data/models/product.dart';

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
        children: [
          Obx(() => InputDecorator(
                decoration: const InputDecoration(labelText: 'Category'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedCategory.value,
                    isDense: true,
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
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16.h),
          Obx(() => Row(
                children: [
                  const Text('Active'),
                  const Spacer(),
                  Switch(
                    value: controller.selectedStatus.value,
                    onChanged: (v) => controller.selectedStatus.value = v,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/dimensions.dart';
import '../controllers/cart_item.dart';
import '../controllers/pos_controller.dart';

class CartTile extends StatelessWidget {
  final int index;
  final CartItem item;
  final PosController controller;

  const CartTile({
    super.key,
    required this.index,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.product.namaProduk,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => controller.removeItem(index),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.decQty(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  constraints: const BoxConstraints(
                      minWidth: AppDimensions.touchTarget,
                      minHeight: AppDimensions.touchTarget),
                ),
                Text('${item.qty}', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  onPressed: () => controller.incQty(index),
                  icon: const Icon(Icons.add_circle_outline),
                  constraints: const BoxConstraints(
                      minWidth: AppDimensions.touchTarget,
                      minHeight: AppDimensions.touchTarget),
                ),
                const Spacer(),
                Text('Rp ${item.subtotal.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            SizedBox(height: 6.h),
            TextField(
              onChanged: (v) => controller.updateNote(index, v),
              decoration: InputDecoration(
                hintText: 'Note (optional)',
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

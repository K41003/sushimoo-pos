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
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.namaProduk,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.18,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Rp ${item.product.harga.toStringAsFixed(0)} each',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove item',
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                  onPressed: () => controller.removeItem(index),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onTap: () => controller.decQty(index),
                ),
                SizedBox(
                  width: 44.w,
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: () => controller.incQty(index),
                ),
                const Spacer(),
                Text(
                  'Rp ${item.subtotal.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              onChanged: (v) => controller.updateNote(index, v),
              decoration: InputDecoration(
                hintText: 'Note (optional)',
                isDense: true,
                filled: true,
                prefixIcon: const Icon(Icons.edit_note_outlined),
                fillColor: scheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: AppDimensions.touchTarget.w,
      height: AppDimensions.touchTarget.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(
            AppDimensions.touchTarget.w,
            AppDimensions.touchTarget.h,
          ),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
          ),
        ),
        child: Icon(icon, size: 20.sp),
      ),
    );
  }
}

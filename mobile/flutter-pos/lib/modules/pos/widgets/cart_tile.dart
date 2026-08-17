import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/cart_item.dart';
import '../controllers/pos_controller.dart';

/// REPLACES `cart_tile.dart` 1:1 — same class name `CartTile`, same
/// constructor (`index`, `item`, `controller`).
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
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      child: GlassPanel(
        radius: AppDimensions.radiusMd,
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
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Rp ${item.product.harga.toStringAsFixed(0)} each',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => controller.removeItem(index),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Icon(Icons.close, size: 18.sp, color: AppColors.inkFaint),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                _StepperButton(icon: Icons.remove, onTap: () => controller.decQty(index)),
                SizedBox(
                  width: 40.w,
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
                _StepperButton(icon: Icons.add, onTap: () => controller.incQty(index)),
                const Spacer(),
                Text(
                  'Rp ${item.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.salmonDark),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
              ),
              child: TextField(
                onChanged: (v) => controller.updateNote(index, v),
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Add a note',
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.edit_note_outlined, size: 18.sp, color: AppColors.inkFaint),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
      child: Container(
        width: 36.r,
        height: 36.r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
          border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
        ),
        child: Icon(icon, size: 16.sp, color: AppColors.ink),
      ),
    );
  }
}

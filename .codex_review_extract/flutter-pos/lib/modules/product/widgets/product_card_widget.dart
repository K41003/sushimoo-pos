import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../data/models/product.dart';
import '../../../shared/widgets/glass_panel.dart';

/// Kept as a free function so existing call sites (`money(product.harga)`)
/// elsewhere in the codebase keep compiling.
String money(dynamic v) => 'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';

/// REPLACES `product_card_widget.dart` 1:1 — same class name
/// `ProductCardWidget`, same constructor (`product`, `onTap`, `onDelete`).
class ProductCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      padding: EdgeInsets.all(14.r),
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.salmonSoft.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14.r),
                    image: (product.gambar != null && product.gambar!.trim().isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(product.gambar!.trim()),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          )
                        : null,
                  ),
                  child: product.gambar == null
                      ? Center(
                          child: Icon(Icons.fastfood, size: 44.sp, color: AppColors.salmon),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                product.namaProduk,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 15.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                money(product.harga),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.salmonDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15.sp,
                    ),
              ),
              if (!product.status) ...[
                SizedBox(height: 4.h),
                Text(
                  'Inactive',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          Positioned(
            top: 2.h,
            right: 2.w,
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.danger,
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

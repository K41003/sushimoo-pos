import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/product.dart';
import '../../../shared/widgets/app_card.dart';

String money(dynamic v) =>
    'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';

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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      onLongPress: onDelete,
      borderRadius: BorderRadius.circular(16.r),
      child: AppCard(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                 decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12.r),
                  image: (product.gambar != null &&
                          product.gambar!.trim().isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(product.gambar!.trim()),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                    child: product.gambar == null
                        ? Center(
                            child: Icon(Icons.fastfood,
                                size: 48.sp, color: scheme.outline),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  product.namaProduk,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  money(product.harga),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (!product.status) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Inactive',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: scheme.error,
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

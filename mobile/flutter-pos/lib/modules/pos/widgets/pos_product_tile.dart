import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../data/models/product.dart';

String moneyShort(dynamic v) => 'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';

/// POS grid tile — clean product card: salmon-tinted image area (no photo
/// placeholder icon soup), bold price, single tap to add to cart.
class PosProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const PosProductTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          border: Border.all(color: AppColors.hairline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: AppColors.salmonSoft,
                child: (product.gambar != null && product.gambar!.trim().isNotEmpty)
                    ? Image.network(
                        product.gambar!.trim(),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _initials(context),
                      )
                    : _initials(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.namaProduk,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          moneyShort(product.harga),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.priceCompact,
                        ),
                      ),
                      Container(
                        width: 30.r,
                        height: 30.r,
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                        ),
                        child: Icon(Icons.add, size: 18.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    final words = product.namaProduk
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .toList();
    final text = words.isEmpty ? 'SM' : words.map((w) => w[0].toUpperCase()).join();
    return Text(
      text,
      style: TextStyle(
        fontSize: 30.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.salmon,
      ),
    );
  }
}

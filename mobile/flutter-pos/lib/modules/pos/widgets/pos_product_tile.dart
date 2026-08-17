import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../data/models/product.dart';
import '../../../shared/widgets/glass_panel.dart';

String moneyShort(dynamic v) => 'Rp ${(v is num ? v : 0).toStringAsFixed(0)}';

/// REPLACES `pos_product_tile.dart` 1:1 — same class name
/// `PosProductTile`, same constructor (`product`, `onTap`).
class PosProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const PosProductTile({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusLg,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg.r)),
              child: Container(
                alignment: Alignment.center,
                color: AppColors.salmonSoft.withValues(alpha: 0.7),
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
                  style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                        gradient: AppColors.salmonGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                        boxShadow: AppColors.shadowSalmon,
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
      style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w800, color: AppColors.salmon),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../data/models/product.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/pos_controller.dart';
import '../widgets/cart_tile.dart';

class PosPage extends GetView<PosController> {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'POS',
      currentRoute: '/pos',
      body: Responsive.isLandscapeTablet(context)
          ? _landscape(context)
          : _portrait(context),
    );
  }

  /// Navigation Rail (categories) + Master View (product grid) + Cart sidebar.
  Widget _landscape(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 232.w,
            child: _categoryRail(context),
          ),
          Expanded(
            child: _menuPanel(context, crossAxisCount: 4),
          ),
          Container(
            width: 392.w,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border(
                left: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: _cart(context, elevated: false),
          ),
        ],
      ),
    );
  }

  Widget _portrait(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _mobileHeader(context),
            _categoryStrip(context),
            Expanded(child: _menuPanel(context, crossAxisCount: 2)),
          ],
        ),
        Positioned(
          right: 16.w,
          bottom: 16.h,
          child: Obx(
            () => FloatingActionButton.extended(
              onPressed: () => _showCartSheet(context),
              label: Text('Cart (${controller.cart.length})'),
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryRail(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MENU',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(letterSpacing: 1.2)),
                SizedBox(height: 6.h),
                Text('Categories',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                itemCount: controller.categories.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, index) {
                  final category = controller.categories[index];
                  final selected = controller.selectedCategoryId.value ==
                      category.idKategori;
                  return _CategoryButton(
                    label: category.namaKategori,
                    selected: selected,
                    onTap: () => controller.selectCategory(category.idKategori),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sushimoo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 1.2,
                        )),
                Text('Point of Sale',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Obx(
            () => _CartBadge(
              count: controller.cart.length,
              total: controller.grandTotal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryStrip(BuildContext context) {
    return SizedBox(
      height: 64.h,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 8.w),
          itemBuilder: (_, index) {
            final c = controller.categories[index];
            return AppChip(
              label: c.namaKategori,
              selected: controller.selectedCategoryId.value == c.idKategori,
              onTap: () => controller.selectCategory(c.idKategori),
            );
          },
        ),
      ),
    );
  }

  Widget _menuPanel(BuildContext context, {required int crossAxisCount}) {
    return Column(
      children: [
        _menuHeader(context),
        Expanded(
          child: Obx(
            () {
              if (controller.loading.value) return const AppLoading();
              if (controller.products.isEmpty) return _emptyMenu(context);
              return GridView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: crossAxisCount > 2 ? 0.96 : 0.9,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: controller.products.length,
                itemBuilder: (_, i) => _ProductTile(
                  product: controller.products[i],
                  onTap: () => controller.addToCart(controller.products[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _menuHeader(BuildContext context) {
    return Obx(
      () {
        String? category;
        for (final item in controller.categories) {
          if (item.idKategori == controller.selectedCategoryId.value) {
            category = item.namaKategori;
            break;
          }
        }
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category ?? 'Menu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${controller.products.length} items available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 128.w,
                height: AppDimensions.buttonHeight.h,
                child: OutlinedButton.icon(
                  onPressed: controller.loadTables,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(128.w, AppDimensions.buttonHeight.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                  icon: const Icon(Icons.sync_outlined),
                  label: const Text('Refresh'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyMenu(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 280.w,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ramen_dining_outlined,
                size: 40.sp, color: scheme.onSurfaceVariant),
            SizedBox(height: 12.h),
            Text('No menu items',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 4.h),
            Text(
              'Select another category or refresh the menu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cart(BuildContext context, {bool elevated = true}) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(() => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Current Order',
                            style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      IconButton(
                        tooltip: 'Clear cart',
                        onPressed: controller.cart.isEmpty
                            ? null
                            : controller.clearCart,
                        icon: const Icon(Icons.delete_sweep_outlined),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: controller.selectTable,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd.r),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: AppDimensions.buttonHeight.h,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: elevated
                            ? scheme.surfaceContainerLow
                            : scheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd.r),
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.table_restaurant_outlined,
                              color: scheme.onSurfaceVariant),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TABLE',
                                    style:
                                        Theme.of(context).textTheme.labelSmall),
                                Text(
                                  controller.selectedTable.value?.nomorMeja ??
                                      'Select table',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.cart.isEmpty
                  ? _emptyCart(context)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: controller.cart.length,
                      itemBuilder: (_, i) => CartTile(
                        index: i,
                        item: controller.cart[i],
                        controller: controller,
                      ),
                    ),
            ),
            _summary(context),
          ],
        ));
  }

  Widget _emptyCart(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 44.sp, color: scheme.onSurfaceVariant),
            SizedBox(height: 12.h),
            Text('Cart is empty',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 4.h),
            Text(
              'Tap menu items to start an order.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryRow(context, 'Subtotal', controller.subtotal),
              SizedBox(height: 8.h),
              _summaryRow(context, 'Tax', controller.tax),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(color: scheme.outlineVariant),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Grand Total',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                  ),
                  Text(
                    _money(controller.grandTotal),
                    style: AppTypography.price(
                        Theme.of(context).brightness == Brightness.dark),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Obx(() => AppButton(
                    label: 'Place Order',
                    icon: Icons.receipt_long_outlined,
                    loading: controller.loading.value,
                    onPressed: controller.cart.isEmpty ? null : controller.placeOrder,
                  )),
            ],
          )),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          _money(value),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        maxChildSize: 0.94,
        minChildSize: 0.48,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXl.r),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: _cart(context),
          ),
        ),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: BoxConstraints(minHeight: AppDimensions.buttonHeight.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: selected ? scheme.onPrimary : scheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected ? scheme.onPrimary : scheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
          border:
              Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isDark ? 0.16 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark
                      ? scheme.surfaceContainerHigh
                      : scheme.surfaceContainerLow,
                ),
                child: Text(
                  _initials(product.namaProduk),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: scheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.namaProduk,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.16,
                        ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _money(product.harga),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color:
                                    isDark ? scheme.primary : scheme.secondary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: scheme.secondary,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm.r),
                        ),
                        child: Icon(Icons.add,
                            size: 20.sp, color: scheme.onSecondary),
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
}

class _CartBadge extends StatelessWidget {
  final int count;
  final double total;

  const _CartBadge({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: BoxConstraints(maxWidth: 188.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 18.sp, color: scheme.onPrimary),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              '$count - ${_money(total)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

String _money(double value) => 'Rp ${value.toStringAsFixed(0)}';

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .toList();
  if (words.isEmpty) return 'SM';
  return words.map((word) => word[0].toUpperCase()).join();
}

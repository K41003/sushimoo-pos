import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/pos_product_tile.dart';
import '../controllers/pos_controller.dart';
import '../widgets/cart_tile.dart';

/// POS screen — "Minimalis Putih" flagship layout.
///
/// Tablet landscape: clean 2-column split — left is the product grid
/// (borderless-feeling cards on white), right is a compact, ungreedy cart
/// summary in a salmon-tinted panel with one bold emerald checkout button.
/// Every tap target is large; the whole order flow is reachable in the
/// number of taps it takes to add items, pick a table, and confirm.
class PosPage extends GetView<PosController> {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'POS',
      currentRoute: '/pos',
      body: Responsive.isLandscapeTablet(context) ? _landscape(context) : _portrait(context),
    );
  }

  Widget _landscape(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _menuPanel(context, crossAxisCount: 4),
          ),
          Container(width: 1, color: AppColors.hairline),
          SizedBox(
            width: 396.w,
            child: Container(
              color: AppColors.salmonSoft.withValues(alpha: 0.4),
              child: _cart(context),
            ),
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
            _searchBar(context),
            Obx(() => controller.isSearching
                ? const SizedBox.shrink()
                : _categoryStrip(context)),
            Expanded(child: _menuGridOnly(context, crossAxisCount: 2)),
          ],
        ),
        Positioned(
          right: 18.w,
          bottom: 18.h,
          child: Obx(
            () => FloatingActionButton.extended(
              onPressed: () => _showCartSheet(context),
              label: Text('Cart (${controller.cart.length})'),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ),
      ],
    );
  }

  /// Grid-only body (no header/search bar) reused by the portrait layout,
  /// since the search bar there lives above this widget, not inside it.
  Widget _menuGridOnly(BuildContext context, {required int crossAxisCount}) {
    return Obx(() {
      if (controller.loading.value) return const AppLoading();
      if (controller.products.isEmpty) {
        return controller.isSearching ? _emptySearch(context) : _emptyMenu(context);
      }
      return GridView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.88,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: controller.products.length,
        itemBuilder: (_, i) => PosProductTile(
          product: controller.products[i],
          onTap: () => controller.addToCart(controller.products[i]),
        ),
      );
    });
  }

  // ---- Left: menu / product grid -----------------------------------

  Widget _menuPanel(BuildContext context, {required int crossAxisCount}) {
    return Column(
      children: [
        _menuHeader(context, crossAxisCount: crossAxisCount),
        _searchBar(context),
        Obx(() => controller.isSearching
            ? const SizedBox.shrink()
            : (crossAxisCount > 2 ? _categoryStrip(context, dense: true) : const SizedBox.shrink())),
        Expanded(
          child: Obx(() {
            if (controller.loading.value) return const AppLoading();
            if (controller.products.isEmpty) {
              return controller.isSearching
                  ? _emptySearch(context)
                  : _emptyMenu(context);
            }
            return GridView.builder(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: crossAxisCount > 2 ? 0.92 : 0.88,
                crossAxisSpacing: 18.w,
                mainAxisSpacing: 18.h,
              ),
              itemCount: controller.products.length,
              itemBuilder: (_, i) => PosProductTile(
                product: controller.products[i],
                onTap: () => controller.addToCart(controller.products[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// Free-text product search — lets the cashier find an item instantly
  /// without tapping a category chip first. Searches across every
  /// category; clearing the field restores the previously selected one.
  Widget _searchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 4.h),
      child: TextField(
        onChanged: controller.onSearchChanged,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: 'Search menu...',
          prefixIcon: Icon(Icons.search, size: 22.sp, color: AppColors.inkMuted),
          suffixIcon: Obx(() => controller.isSearching
              ? IconButton(
                  icon: Icon(Icons.close, size: 18.sp, color: AppColors.inkMuted),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            borderSide: const BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
            borderSide: const BorderSide(color: AppColors.ink, width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget _emptySearch(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40.sp, color: AppColors.inkFaint),
            SizedBox(height: 14.h),
            Text('No results', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 6.h),
            Text(
              'Try a different product name.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuHeader(BuildContext context, {required int crossAxisCount}) {
    return Obx(() {
      String? category;
      for (final item in controller.categories) {
        if (item.idKategori == controller.selectedCategoryId.value) {
          category = item.namaKategori;
          break;
        }
      }
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, crossAxisCount > 2 ? 4.h : 10.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MENU',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(letterSpacing: 1.4)),
                  SizedBox(height: 4.h),
                  Text(
                    category ?? 'All Items',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: controller.loadTables,
              icon: Icon(Icons.sync_outlined, size: 22.sp, color: AppColors.inkMuted),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceAlt,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                ),
                minimumSize: Size(46.r, 46.r),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _categoryStrip(BuildContext context, {bool dense = false}) {
    return SizedBox(
      height: 56.h,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 10.w),
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

  Widget _mobileHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sushimoo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
                Text('Point of Sale', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyMenu(BuildContext context) {
    return Center(
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ramen_dining_outlined, size: 40.sp, color: AppColors.inkFaint),
            SizedBox(height: 14.h),
            Text('No menu items', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 6.h),
            Text(
              'Select another category or refresh the menu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ---- Right: cart summary -------------------------------------------

  Widget _cart(BuildContext context) {
    return Obx(() => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Current Order', style: Theme.of(context).textTheme.headlineMedium),
                      ),
                      IconButton(
                        tooltip: 'Clear cart',
                        onPressed: controller.cart.isEmpty ? null : controller.clearCart,
                        icon: Icon(Icons.delete_outline,
                            size: 20.sp,
                            color: controller.cart.isEmpty ? AppColors.inkFaint : AppColors.danger),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  InkWell(
                    onTap: controller.selectTable,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                    child: Container(
                      constraints: BoxConstraints(minHeight: AppDimensions.buttonHeight.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.table_restaurant_outlined, size: 20.sp, color: AppColors.ink),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TABLE', style: Theme.of(context).textTheme.labelSmall),
                                Text(
                                  controller.selectedTable.value?.nomorMeja ?? 'Select table',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 20.sp, color: AppColors.inkFaint),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.surface,
                child: controller.cart.isEmpty
                    ? _emptyCart(context)
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        itemCount: controller.cart.length,
                        itemBuilder: (_, i) =>
                            CartTile(index: i, item: controller.cart[i], controller: controller),
                      ),
              ),
            ),
            _summary(context),
          ],
        ));
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 42.sp, color: AppColors.inkFaint),
            SizedBox(height: 14.h),
            Text('Cart is empty', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 6.h),
            Text(
              'Tap menu items to start an order.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summaryRow(context, 'Subtotal', controller.subtotal),
              SizedBox(height: 8.h),
              _summaryRow(context, 'Tax', controller.tax),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                child: const Divider(),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text('Grand Total', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Text(_money(controller.grandTotal), style: AppTypography.price),
                ],
              ),
              SizedBox(height: 16.h),
              Obx(() => AppButton(
                    label: 'Bayar / Checkout',
                    icon: Icons.arrow_forward_rounded,
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
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.ink),
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
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, __) => ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl.r)),
          child: Material(color: AppColors.surface, child: _cart(context)),
        ),
      ),
    );
  }
}

String _money(double value) => 'Rp ${value.toStringAsFixed(0)}';

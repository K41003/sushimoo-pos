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
import '../../../shared/widgets/glass_panel.dart';
import '../widgets/pos_product_tile.dart';
import '../controllers/pos_controller.dart';
import '../widgets/cart_tile.dart';

/// REPLACES `pos_page.dart` 1:1 — same class name `PosPage`, same
/// `GetView<PosController>`. Layout logic (landscape split / portrait
/// bottom-sheet cart) is unchanged; only the visual layer is glass now.
///
/// STRUCTURAL FIX (this pass): category chips and the "MENU" title were
/// not updating when a different category was tapped, even though
/// `PosController.selectCategory` was confirmed to update
/// `selectedCategoryId.value` correctly — the products grid (reading a
/// different `Rx` on the same controller) updated fine every time.
///
/// Several rounds of simplifying the `Obx` wrapping around the header and
/// chip strip (collapsing nested `Obx`, adding explicit `Key`s) made no
/// difference, which means the problem wasn't the shape of the reactive
/// scope — something about those specific `Obx` widgets in this
/// particular tree was not receiving updates.
///
/// Rather than keep patching individual `Obx` blocks, the entire page
/// body is now driven by ONE top-level `GetX<PosController>` builder.
/// `GetX` rebuilds its whole builder function on ANY change to an
/// observed `Rx`/`Rxn` on the bound controller — there's no per-widget
/// subscription bookkeeping left that could go stale or fail to attach.
/// Every value read below (`c.selectedCategoryId`, `c.categories`,
/// `c.products`, `c.cart`, etc.) now comes from the single `c` instance
/// handed to this one builder, so there is no more room for a reactive
/// widget to end up reading from a different scope than the one that
/// was updated.
class PosPage extends GetView<PosController> {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'POS',
      currentRoute: '/pos',
      body: GetX<PosController>(
        builder: (c) {
          return Responsive.isLandscapeTablet(context)
              ? _landscape(context, c)
              : _portrait(context, c);
        },
      ),
    );
  }

  Widget _landscape(BuildContext context, PosController c) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _menuPanel(context, c, crossAxisCount: 4),
        ),
        SizedBox(
          width: 400.w,
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 4.h, AppDimensions.sm.w, AppDimensions.sm.h),
            child: GlassPanel(
              radius: AppDimensions.radiusXl,
              padding: EdgeInsets.zero,
              opacity: 0.5,
              child: _cart(context, c),
            ),
          ),
        ),
      ],
    );
  }

  Widget _portrait(BuildContext context, PosController c) {
    return Stack(
      children: [
        Column(
          children: [
            _mobileHeader(context),
            _searchBar(context, c),
            if (!c.isSearching) _categoryStrip(context, c),
            Expanded(child: _menuGrid(context, c, crossAxisCount: 2)),
          ],
        ),
        Positioned(
          right: AppDimensions.md.w,
          bottom: AppDimensions.md.h,
          child: FloatingActionButton.extended(
            onPressed: () => _showCartSheet(context, c),
            label: Text('Cart (${c.cart.length})'),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ),
      ],
    );
  }

  Widget _menuGrid(BuildContext context, PosController c, {required int crossAxisCount}) {
    if (c.loading.value) return const AppLoading();
    if (c.products.isEmpty) {
      return c.isSearching ? _emptySearch(context) : _emptyMenu(context);
    }
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(AppDimensions.lg.w, AppDimensions.xs.h, AppDimensions.lg.w, AppDimensions.lg.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount > 2 ? 0.92 : 0.88,
        crossAxisSpacing: AppDimensions.md.w,
        mainAxisSpacing: AppDimensions.md.h,
      ),
      itemCount: c.products.length,
      itemBuilder: (_, i) => PosProductTile(
        product: c.products[i],
        onTap: () => c.addToCart(c.products[i]),
      ),
    );
  }

  Widget _menuPanel(BuildContext context, PosController c, {required int crossAxisCount}) {
    return Column(
      children: [
        _menuHeader(context, c, crossAxisCount: crossAxisCount),
        _searchBar(context, c),
        if (!c.isSearching && crossAxisCount > 2) _categoryStrip(context, c, dense: true),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w),
            child: _menuGrid(context, c, crossAxisCount: crossAxisCount),
          ),
        ),
      ],
    );
  }

  Widget _searchBar(BuildContext context, PosController c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimensions.xl.w, 10.h, AppDimensions.xl.w, 4.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
        ),
        child: TextField(
          onChanged: c.onSearchChanged,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: 'Search menu...',
            prefixIcon: Icon(Icons.search, size: 22.sp, color: AppColors.inkMuted),
            suffixIcon: c.isSearching
                ? IconButton(
                    icon: Icon(Icons.close, size: 18.sp, color: AppColors.inkMuted),
                    onPressed: c.clearSearch,
                  )
                : const SizedBox.shrink(),
            filled: false,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
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

  Widget _menuHeader(BuildContext context, PosController c, {required int crossAxisCount}) {
    String? category;
    for (final item in c.categories) {
      if (item.idKategori == c.selectedCategoryId.value) {
        category = item.namaKategori;
        break;
      }
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimensions.xl.w, AppDimensions.xl.h, AppDimensions.xl.w, crossAxisCount > 2 ? 4.h : 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MENU', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.4)),
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
          GlassIconButton(
            icon: Icons.sync_outlined,
            onPressed: c.loadTables,
          ),
        ],
      ),
    );
  }

  Widget _categoryStrip(BuildContext context, PosController c, {bool dense = false}) {
    return SizedBox(
      height: 56.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.xl.w, vertical: 6.h),
        itemCount: c.categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, index) {
          final cat = c.categories[index];
          final isSelected = c.selectedCategoryId.value == cat.idKategori;
          return AppChip(
            key: ValueKey('cat_chip_${cat.idKategori}_$isSelected'),
            label: cat.namaKategori,
            selected: isSelected,
            onTap: () => c.selectCategory(cat.idKategori),
          );
        },
      ),
    );
  }

  Widget _mobileHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppDimensions.lg.w, AppDimensions.lg.h, AppDimensions.lg.w, AppDimensions.xs.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sushimoo', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.2)),
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
      child: GlassPanel(
        radius: AppDimensions.radiusLg,
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

  Widget _cart(BuildContext context, PosController c) {
    return Column(
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
                    onPressed: c.cart.isEmpty ? null : c.clearCart,
                    icon: Icon(Icons.delete_outline,
                        size: 20.sp,
                        color: c.cart.isEmpty ? AppColors.inkFaint : AppColors.danger),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.sm.h),
              InkWell(
                onTap: c.selectTable,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                child: Container(
                  constraints: BoxConstraints(minHeight: AppDimensions.buttonHeight.h),
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.sm.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                    border: Border.all(color: AppColors.glassBorder(opacity: 0.7)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.table_restaurant_outlined, size: 20.sp, color: AppColors.ink),
                      SizedBox(width: AppDimensions.sm.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TABLE', style: Theme.of(context).textTheme.labelSmall),
                            Text(
                              c.selectedTable.value?.nomorMeja ?? 'Select table',
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.ink),
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
          child: c.cart.isEmpty
              ? _emptyCart(context)
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w),
                  itemCount: c.cart.length,
                  itemBuilder: (_, i) => CartTile(index: i, item: c.cart[i], controller: c),
                ),
        ),
        _summary(context, c),
      ],
    );
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

  Widget _summary(BuildContext context, PosController c) {
    final hasTax = c.tax > 0;
    return Padding(
      padding: EdgeInsets.all(AppDimensions.md.w),
      child: GlassPanel(
        radius: AppDimensions.radiusLg,
        strong: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow(context, 'Subtotal', c.subtotal),
            if (hasTax) ...[
              SizedBox(height: AppDimensions.xs.h),
              _summaryRow(context, 'Tax', c.tax),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.sm.h + 2.h),
              child: const Divider(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Text('Grand Total', style: Theme.of(context).textTheme.bodyLarge)),
                Text(_money(c.grandTotal), style: AppTypography.price),
              ],
            ),
            SizedBox(height: AppDimensions.md.h),
            AppButton(
              label: 'Bayar / Checkout',
              icon: Icons.arrow_forward_rounded,
              loading: c.loading.value,
              onPressed: c.cart.isEmpty ? null : c.placeOrder,
            ),
          ],
        ),
      ),
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

  void _showCartSheet(BuildContext context, PosController c) {
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
          child: GlassBackground(
            showBlobs: false,
            // Wrapped in its own GetX so the bottom sheet (a separate
            // route/overlay) keeps updating live as cart/category state
            // changes, since it's built outside the page's main GetX scope.
            child: GetX<PosController>(builder: (c2) => _cart(context, c2)),
          ),
        ),
      ),
    );
  }
}

String _money(double value) => 'Rp ${value.toStringAsFixed(0)}';

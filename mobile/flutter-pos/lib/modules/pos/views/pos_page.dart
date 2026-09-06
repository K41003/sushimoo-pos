import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/themes/theme.dart';
import '../../../shared/utils/responsive.dart' show Responsive, DeviceClass;
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
/// =====================================================================
/// UX FIX (design review P0 #2): previously the ONLY way to place a
/// takeaway order was to open the full table-picker sheet (`selectTable`)
/// and hope there was a "no table" option in it — there wasn't one in
/// the controller logic at all. Every single order, including
/// high-volume takeaway business, forced the sheet open.
///
/// `_cart()`'s table-select row is now a two-part control: the existing
/// "TABLE" selector (unchanged tap target/behavior, opens the sheet) sits
/// next to a new explicit "TAKEAWAY" quick-select button that calls
/// `PosController.setTakeaway()` directly — one tap, no sheet, no
/// scrolling to find an implicit option that never existed. Selecting an
/// actual table afterwards still works exactly as before and clears the
/// takeaway flag (mutual exclusivity handled in the controller).
class PosPage extends GetView<PosController> {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'POS',
      currentRoute: '/pos',
      body: GetX<PosController>(
        builder: (c) {
          // CORRECTION: `Responsive.isLandscapeTablet` no longer exists
          // — orientation is now locked per device at startup, so
          // "tablet" and "tablet in landscape" are the same state.
          // `_landscape`/`_portrait` here are kept as method names for
          // minimal diff, but now correctly mean "tablet layout" /
          // "phone layout" rather than literal orientation.
          return Responsive.classOf(context) == DeviceClass.tablet
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
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.salmonGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
              boxShadow: AppColors.shadowSalmon,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showCartSheet(context, c),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        'Cart (${c.cart.length})',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
              // UX FIX (P0 #2): table selector + new one-tap takeaway
              // button side by side. Table button keeps its original tap
              // target/behavior; Takeaway is new and calls
              // `c.setTakeaway()` directly with zero intermediate sheet.
              // Wrapped in IntrinsicHeight so both cards visually align
              // to the same height (whichever is taller) WITHOUT the
              // infinite-height bug `CrossAxisAlignment.stretch` caused
              // above — IntrinsicHeight computes a bounded height from
              // the children first, then sizes the Row to that, instead
              // of asking children to stretch into an as-yet-undetermined
              // parent height.
              IntrinsicHeight(
                child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: c.selectTable,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                      child: Container(
                        constraints: BoxConstraints(minHeight: AppDimensions.buttonHeight.h),
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.sm.h),
                        decoration: BoxDecoration(
                          color: (!c.isTakeaway.value)
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.25),
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
                                    (!c.isTakeaway.value)
                                        ? (c.selectedTable.value?.nomorMeja ?? 'Select table')
                                        : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                  ),
                  SizedBox(width: AppDimensions.sm.w),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: c.setTakeaway,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        constraints: BoxConstraints(minHeight: AppDimensions.buttonHeight.h),
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm.w, vertical: AppDimensions.sm.h),
                        decoration: BoxDecoration(
                          gradient: c.isTakeaway.value ? AppColors.salmonGradient : null,
                          color: c.isTakeaway.value ? null : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                          border: Border.all(
                            color: c.isTakeaway.value
                                ? Colors.transparent
                                : AppColors.glassBorder(opacity: 0.7),
                            width: 1.2,
                          ),
                          boxShadow: c.isTakeaway.value ? AppColors.shadowSalmon : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 20.sp,
                              color: c.isTakeaway.value ? Colors.white : AppColors.ink,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'TAKEAWAY',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: c.isTakeaway.value ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    final canCheckout = c.cart.isNotEmpty;
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
              onPressed: canCheckout ? c.placeOrder : null,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
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
    return Row(
      children: [
        SizedBox(
          width: 200.w,
          child: Obx(() => ListView(
                padding: EdgeInsets.all(8.w),
                children: controller.categories
                    .map((c) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: AppChip(
                            label: c.namaKategori,
                            selected:
                                controller.selectedCategoryId.value == c.idKategori,
                            onTap: () => controller.selectCategory(c.idKategori),
                          ),
                        ))
                    .toList(),
              )),
        ),
        Expanded(
          flex: 3,
          child: Obx(() => controller.loading.value
              ? const AppLoading()
              : GridView.builder(
                  padding: EdgeInsets.all(12.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                  itemCount: controller.products.length,
                  itemBuilder: (_, i) {
                    final p = controller.products[i];
                    return AppCard(
                      onTap: () => controller.addToCart(p),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.namaProduk,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 6.h),
                            Text('Rp ${p.harga.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    );
                  },
                )),
        ),
        Container(
          width: 360.w,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: _cart(context),
        ),
      ],
    );
  }

  Widget _portrait(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 56.h,
              child: Obx(() => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(8.w),
                    children: controller.categories
                        .map((c) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: AppChip(
                                label: c.namaKategori,
                                selected: controller.selectedCategoryId.value ==
                                    c.idKategori,
                                onTap: () => controller.selectCategory(c.idKategori),
                              ),
                            ))
                        .toList(),
                  )),
            ),
            Expanded(
              child: Obx(() => controller.loading.value
                  ? const AppLoading()
                  : GridView.builder(
                      padding: EdgeInsets.all(12.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: controller.products.length,
                      itemBuilder: (_, i) {
                        final p = controller.products[i];
                        return AppCard(
                          onTap: () => controller.addToCart(p),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(p.namaProduk,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyLarge),
                                SizedBox(height: 6.h),
                                Text('Rp ${p.harga.toStringAsFixed(0)}',
                                    style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
            ),
          ],
        ),
        Positioned(
          right: 16.w,
          bottom: 16.h,
          child: Obx(() => FloatingActionButton.extended(
                onPressed: () => _showCartSheet(context),
                label: Text('Cart (${controller.cart.length})'),
                icon: const Icon(Icons.shopping_cart),
              )),
        ),
      ],
    );
  }

  Widget _cart(BuildContext context) {
    return Obx(() => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.selectTable,
                      child: Text(controller.selectedTable.value?.nomorMeja ??
                          'Select Table'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: controller.cart.length,
                itemBuilder: (_, i) =>
                    CartTile(index: i, item: controller.cart[i], controller: controller),
              ),
            ),
            _summary(context),
          ],
        ));
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('Rp ${controller.subtotal.toStringAsFixed(0)}'),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rp ${controller.grandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12.h),
              AppButton(
                label: 'Place Order',
                loading: controller.loading.value,
                onPressed: controller.placeOrder,
              ),
            ],
          )),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        builder: (_, __) => Scaffold(
          appBar: AppBar(title: const Text('Cart')),
          body: _cart(context),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../controllers/closing_controller.dart';

class ClosingPage extends GetView<ClosingController> {
  const ClosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Closing',
      currentRoute: AppRoutes.closing,
      body: Obx(() {
        if (controller.loading.value) return const AppLoading();
        return SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.marginTablet.w),
          child: Column(
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Shift',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text(controller.activeShift.value != null
                        ? 'Shift #${controller.activeShift.value!.idShift} is open'
                        : 'No active shift'),
                    SizedBox(height: 16.h),
                    Obx(() => AppButton(
                          label: 'Closing Kasir',
                          primary: controller.activeShift.value != null,
                          onPressed: controller.activeShift.value != null
                              ? controller.doClosing
                              : null,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              if (controller.lastClosing.value != null)
                _reportCard(context, controller.lastClosing.value!),
              SizedBox(height: 16.h),
              Text('Closing History', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8.h),
              ...controller.history
                  .map((c) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _reportCard(context, c),
                      ))
                  ,
            ],
          ),
        );
      }),
    );
  }

  Widget _reportCard(BuildContext context, dynamic c) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Closing #${c.idClosing}',
              style: Theme.of(context).textTheme.bodyLarge),
          SizedBox(height: 6.h),
          Text('Total Penjualan: Rp ${c.totalPenjualan.toStringAsFixed(0)}'),
          Text('Total Cash: Rp ${c.totalCash.toStringAsFixed(0)}'),
          Text('Total QRIS: Rp ${c.totalQris.toStringAsFixed(0)}'),
          Text('Total Pengeluaran: Rp ${c.totalPengeluaran.toStringAsFixed(0)}'),
          Text('Saldo Akhir: Rp ${c.saldoAkhir.toStringAsFixed(0)}'),
        ],
      ),
    );
  }
}

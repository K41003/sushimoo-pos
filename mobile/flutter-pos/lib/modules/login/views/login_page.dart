import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/colors.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../controllers/login_controller.dart';

/// REPLACES `login_page.dart` 1:1 — same class name `LoginPage`, same
/// `GetView<LoginController>`, so `LoginBinding` + `app_pages.dart` need
/// zero changes. Visual layer rebuilt as Glassmorphic Zen: gradient
/// canvas + floating color blobs behind a frosted login card.
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 768;
              return Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all((isTablet ? 40 : 20).r),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: isTablet ? 460.w : double.infinity),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _brandStamp(context),
                        SizedBox(height: 32.h),
                        _loginCard(context),
                        SizedBox(height: 20.h),
                        Text(
                          'Gunakan username "admin" password "password" untuk uji coba.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11.5.sp, color: AppColors.inkFaint),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _brandStamp(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76.r,
          height: 76.r,
          decoration: BoxDecoration(
            gradient: AppColors.salmonGradient,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: AppColors.shadowSalmon,
          ),
          child: Icon(Icons.restaurant_menu, color: Colors.white, size: 34.sp),
        ),
        SizedBox(height: 16.h),
        Text('SUSHIMOO', style: Theme.of(context).textTheme.displayLarge),
        SizedBox(height: 4.h),
        Text(
          'Zen Precision Restaurant POS',
          style: TextStyle(
              fontSize: 13.sp, color: AppColors.inkMuted, letterSpacing: 0.4),
        ),
      ],
    );
  }

  Widget _loginCard(BuildContext context) {
    return GlassPanel(
      radius: AppDimensions.radiusXl.r,
      strong: true,
      padding: EdgeInsets.all(AppDimensions.xl.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const StatusChip(status: 'open'),
              const Spacer(),
              Text('Cashier Login',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
          SizedBox(height: 24.h),
          AppTextField(
            label: 'Username',
            hint: 'Masukkan username',
            controller: controller.usernameController,
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: 'Password',
            hint: 'Masukkan password',
            controller: controller.passwordController,
            obscure: true,
          ),
          SizedBox(height: 24.h),
          Obx(() => AppButton(
                label: 'Masuk Ke Sistem',
                icon: Icons.arrow_forward_rounded,
                loading: controller.loading.value,
                onPressed: controller.submit,
              )),
        ],
      ),
    );
  }
}

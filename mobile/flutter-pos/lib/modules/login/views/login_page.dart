import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/constants/dimensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.marginTablet.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420.w),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(28.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 64.sp, color: scheme.primary),
                    SizedBox(height: 12.h),
                    Text('SUSHIMOO POS',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 24.h),
                    AppTextField(
                      label: 'Username',
                      controller: controller.usernameController,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: 'Password',
                      controller: controller.passwordController,
                      obscure: true,
                    ),
                    SizedBox(height: 24.h),
                    Obx(() => AppButton(
                          label: 'Login',
                          loading: controller.loading.value,
                          onPressed: controller.submit,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

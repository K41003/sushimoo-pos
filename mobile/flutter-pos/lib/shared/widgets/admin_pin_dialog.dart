import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import '../../app/services/api_client.dart';
import '../../app/services/local_data_service.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'glass_panel.dart';

class AdminPinDialog {
  static Future<bool> show({
    required String title,
    required String message,
  }) async {
    final result = await Get.dialog<bool>(
      _AdminPinDialogContent(title: title, message: message),
      barrierDismissible: false,
    );
    return result ?? false;
  }
}

class _AdminPinDialogContent extends StatefulWidget {
  final String title;
  final String message;

  const _AdminPinDialogContent({required this.title, required this.message});

  @override
  State<_AdminPinDialogContent> createState() => _AdminPinDialogContentState();
}

class _AdminPinDialogContentState extends State<_AdminPinDialogContent> {
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final username = _usernameController.text.trim();
    final pin = _pinController.text.trim();
    if (username.isEmpty || pin.isEmpty) {
      setState(() => _error = 'Username and PIN are required');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    if (AppConstants.localMode) {
      // "PIN" in local mode is that admin user's own password — verified
      // against the same `users` table Auth uses, and the user must
      // actually hold the Admin role (a cashier's own password does not
      // count as approval).
      final result = await LocalDataService.to.login(username, pin);
      setState(() => _loading = false);
      if (result != null && result.user.isAdmin) {
        Get.back(result: true);
      } else {
        setState(() => _error = 'Invalid admin username or PIN');
      }
      return;
    }

    final res = await ApiClient.to.post(
      '/auth/verify-pin',
      body: {'username': username, 'pin': pin},
    );

    setState(() {
      _loading = false;
    });

    if (res.success) {
      Get.back(result: true);
    } else {
      setState(() => _error = res.message.isNotEmpty
          ? res.message
          : 'Invalid admin PIN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.w),
        child: GlassPanel(
          radius: AppDimensions.radiusXl,
          strong: true,
          padding: EdgeInsets.all(AppDimensions.lg.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.admin_panel_settings_outlined,
                    color: AppColors.warning, size: 24.sp),
              ),
              SizedBox(height: AppDimensions.md.h),
              Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8.h),
              Text(widget.message, style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: AppDimensions.lg.h),
              AppTextField(
                label: 'Admin Username',
                controller: _usernameController,
              ),
              SizedBox(height: 14.h),
              AppTextField(
                label: 'Admin PIN',
                controller: _pinController,
                obscure: true,
                keyboardType: TextInputType.number,
              ),
              if (_error != null) ...[
                SizedBox(height: 10.h),
                Text(
                  _error!,
                  style: TextStyle(color: AppColors.danger, fontSize: 12.5.sp, fontWeight: FontWeight.w600),
                ),
              ],
              SizedBox(height: AppDimensions.lg.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      primary: false,
                      onPressed: _loading ? null : () => Get.back(result: false),
                    ),
                  ),
                  SizedBox(width: AppDimensions.sm.w),
                  Expanded(
                    child: AppButton(
                      label: 'Verify',
                      loading: _loading,
                      onPressed: _verify,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

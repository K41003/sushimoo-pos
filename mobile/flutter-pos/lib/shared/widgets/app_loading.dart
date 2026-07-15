import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/constants/colors.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  const AppLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(strokeWidth: 2.4),
          if (message != null) ...[
            SizedBox(height: 14.h),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ]
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const AppEmptyState({
    super.key,
    this.message = 'No data available',
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.r,
            height: 64.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(icon, size: 28.sp, color: AppColors.inkFaint),
          ),
          SizedBox(height: 14.h),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

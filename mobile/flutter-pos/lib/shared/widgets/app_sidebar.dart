import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  const NavItem(this.label, this.icon, this.route);
}

/// Minimal rail: white background, hairline right border, active item
/// marked with a small ink dot + bold label — no heavy filled pill.
class AppSidebar extends StatelessWidget {
  final List<NavItem> items;
  final String currentRoute;
  final VoidCallback? onLogout;

  const AppSidebar({
    super.key,
    required this.items,
    required this.currentRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        width: AppDimensions.railWidth.w,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(right: BorderSide(color: AppColors.hairline)),
        ),
        child: Column(
          children: [
            SizedBox(height: 28.h),
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.restaurant_menu, size: 20.sp, color: Colors.white),
            ),
            SizedBox(height: 28.h),
            Expanded(
              child: ListView(
                children: items.map((item) {
                  final active = item.route == currentRoute;
                  return InkWell(
                    onTap: () => _navigate(context, item.route),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: active ? AppColors.surfaceAlt : Colors.transparent,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            item.icon,
                            size: 22.sp,
                            color: active ? AppColors.ink : AppColors.inkFaint,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? AppColors.ink : AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (onLogout != null)
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: IconButton(
                  icon: Icon(Icons.logout, color: AppColors.danger, size: 20.sp),
                  onPressed: onLogout,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (route != currentRoute) Get.offAllNamed(route);
  }
}

class AppDrawer extends StatelessWidget {
  final List<NavItem> items;
  final String currentRoute;
  final VoidCallback? onLogout;

  const AppDrawer({
    super.key,
    required this.items,
    required this.currentRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
            child: Text('SUSHIMOO', style: Theme.of(context).textTheme.headlineMedium),
          ),
          ...items.map((item) {
            final active = item.route == currentRoute;
            return ListTile(
              leading: Icon(item.icon, color: active ? AppColors.ink : AppColors.inkMuted),
              title: Text(
                item.label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.ink : AppColors.inkMuted,
                ),
              ),
              selected: active,
              selectedTileColor: AppColors.surfaceAlt,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              onTap: () {
                Get.back();
                if (item.route != currentRoute) Get.offAllNamed(item.route);
              },
            );
          }),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.danger),
              title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              onTap: onLogout,
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/dimensions.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  const NavItem(this.label, this.icon, this.route);
}

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
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: Container(
        width: AppDimensions.railWidth.w,
        color: scheme.surfaceContainerLow,
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Icon(Icons.restaurant_menu, size: 32.sp, color: scheme.primary),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                children: items.map((item) {
                  final active = item.route == currentRoute;
                  return InkWell(
                    onTap: () => _navigate(context, item.route),
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: active ? scheme.primaryContainer : null,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Icon(item.icon,
                              size: 24.sp,
                              color: active
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant),
                          SizedBox(height: 4.h),
                          Text(item.label,
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: active
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (onLogout != null)
              IconButton(
                icon: Icon(Icons.logout, color: scheme.error),
                onPressed: onLogout,
              ),
            SizedBox(height: 12.h),
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
    final scheme = Theme.of(context).colorScheme;
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('SUSHIMOO',
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: item.route == currentRoute,
                onTap: () {
                  Get.back();
                  if (item.route != currentRoute) Get.offAllNamed(item.route);
                },
              )),
          if (onLogout != null)
            ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: const Text('Logout'),
              onTap: onLogout,
            ),
        ],
      ),
    );
  }
}

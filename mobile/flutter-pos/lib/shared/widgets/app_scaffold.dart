import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/storage_service.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/utils/responsive.dart';
import 'nav_item_factory.dart';

/// App shell implementing the Design.md navigation rail / drawer pattern.
/// Wraps every module page with role-aware navigation.
class AppScaffold extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final user = StorageService.to.user;
    final items = navItemsForRole(user?.roleName ?? '');

    final content = Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Center(
                child: Text(user.nama,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ...?actions,
        ],
      ),
      drawer: Responsive.isTablet(context) && !Responsive.isLandscape(context)
          ? AppDrawer(
              items: items,
              currentRoute: currentRoute,
              onLogout: _logout,
            )
          : null,
      body: body,
    );

    if (Responsive.isLandscapeTablet(context)) {
      return Row(
        children: [
          AppSidebar(
            items: items,
            currentRoute: currentRoute,
            onLogout: _logout,
          ),
          Expanded(child: content),
        ],
      );
    }
    return content;
  }

  void _logout() async {
    await AuthService.to.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}

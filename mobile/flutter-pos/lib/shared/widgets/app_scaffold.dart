import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/routes/app_routes.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/storage_service.dart';
import '../../shared/widgets/app_sidebar.dart';
import '../../shared/utils/responsive.dart';
import 'nav_item_factory.dart';

/// App shell: minimal white nav rail (tablet landscape) or drawer (portrait)
/// wrapping every module page.
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  user.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ),
          ...?actions,
          const SizedBox(width: 8),
        ],
      ),
      drawer: Responsive.isTablet(context) && !Responsive.isLandscape(context)
          ? AppDrawer(items: items, currentRoute: currentRoute, onLogout: _logout)
          : null,
      body: body,
    );

    if (Responsive.isLandscapeTablet(context)) {
      return Row(
        children: [
          AppSidebar(items: items, currentRoute: currentRoute, onLogout: _logout),
          Expanded(child: content),
        ],
      );
    }
    return content;
  }

  Future<void> _logout() async {
    try {
      await AuthService.to.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      EasyLoading.showError('Logout failed');
    }
  }
}

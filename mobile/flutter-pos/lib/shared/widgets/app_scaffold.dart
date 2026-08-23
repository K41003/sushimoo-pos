import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/routes/app_routes.dart';
import '../../app/services/auth_service.dart';
import 'app_sidebar.dart';
import 'glass_panel.dart';
import '../../shared/utils/responsive.dart';
import 'nav_item_factory.dart';

/// REPLACES `app_scaffold.dart` 1:1 — same class name `AppScaffold`, same
/// constructor (`title`, `currentRoute`, `body`, `actions`). Now wraps
/// every page body in [GlassBackground] and renders a translucent app
/// bar instead of an opaque one, so every screen using `AppScaffold`
/// automatically gets the Glassmorphic Zen canvas + blobs.
///
/// FIX (role/menu mismatch): previously this read the logged-in user
/// from `StorageService.to.user` (plaintext GetStorage) to decide which
/// sidebar/drawer items to show via `navItemsForRole(user?.roleName)`.
/// After the app migrated auth/session storage to `SecureStorageService`
/// (see `secure_storage_service.dart`, `auth_service.dart`), login only
/// writes the session there — `StorageService`'s copy of the user is
/// never populated anymore. That made `StorageService.to.user` always
/// `null`, so `roleName` fell back to `''`, which `nav_item_factory.dart`
/// treats as "not Admin" -> it always rendered the **Kasir** menu
/// (Shift/POS/Expense/...), even when an Admin was logged in and the
/// Dashboard body correctly showed admin data (because
/// `DashboardController` reads the role from `AuthService`, a different,
/// still-correct source).
///
/// Now both the page body (Dashboard) and the navigation (sidebar/drawer)
/// derive the role from the SAME source — `AuthService.to.currentUser`
/// — so an Admin login always gets the Admin menu:
/// Dashboard/Category/Product/Ingredient/Stock/Table/Report/Closing/Setting,
/// and a Kasir login always gets the Kasir menu:
/// Dashboard/Shift/POS/Expense/Report/Closing/Setting.
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
    // FIX: use AuthService (SecureStorageService-backed) instead of
    // StorageService, so the sidebar/drawer role matches the actual
    // logged-in user's role everywhere else in the app.
    final user = AuthService.to.currentUser;
    final items = navItemsForRole(user?.roleName ?? '');
    final isRail = Responsive.isLandscapeTablet(context);

    final content = Builder(builder: (scaffoldContext) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: _GlassAppBar(
            title: title,
            user: user,
            actions: actions,
            showMenuButton: !isRail,
            onLogout: () => _logout(),
          ),
        ),
        drawer: isRail
            ? null
            : AppDrawer(items: items, currentRoute: currentRoute, onLogout: _logout),
        body: GlassBackground(
          child: Padding(
            padding: const EdgeInsets.only(top: 64),
            child: body,
          ),
        ),
      );
    });

    if (isRail) {
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

class _GlassAppBar extends StatelessWidget {
  final String title;
  final dynamic user;
  final List<Widget>? actions;
  final bool showMenuButton;
  final VoidCallback onLogout;

  const _GlassAppBar({
    required this.title,
    required this.user,
    required this.showMenuButton,
    required this.onLogout,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: GlassPanel(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          blurSigma: AppColors.blurSigmaLight,
          shadow: AppColors.shadowSm,
          child: Row(
            children: [
              if (showMenuButton)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.ink),
                    tooltip: 'Menu',
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              else
                const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    user.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.inkMuted),
                  ),
                ),
              ...?actions,
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                tooltip: 'Logout',
                onPressed: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/routes/app_routes.dart';
import '../../app/services/auth_service.dart';
import '../../app/services/storage_service.dart';
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
/// FIX: the previous version only showed navigation via [AppSidebar] on
/// landscape tablets. On phones / portrait it showed neither a sidebar
/// nor a drawer trigger, leaving the user with no way to switch pages or
/// log out. Now: landscape tablet -> persistent rail; everything else
/// -> a [Scaffold.drawer] opened via an explicit hamburger button in the
/// glass app bar (a custom [PreferredSize] app bar does NOT get Flutter's
/// automatic drawer button, so it must be added by hand).
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

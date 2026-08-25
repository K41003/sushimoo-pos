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
/// constructor (`title`, `currentRoute`, `body`, `actions`). Wraps every
/// page body in [GlassBackground] and renders a translucent app bar, so
/// every screen using `AppScaffold` automatically gets the Glassmorphic
/// Zen canvas + blobs.
///
/// UI CHANGE (this pass):
/// - The top app bar no longer carries a logout icon (kept out of the
///   way of accidental taps mid-transaction) but now shows the logged-in
///   user's name on every screen, so whoever's using the device always
///   knows which account is active.
/// - Logout is back in the sidebar (tablet/landscape rail) and in the
///   drawer (phone/portrait) — both already had the wiring for it via
///   the nullable `onLogout` callback, so this only required passing
///   that callback again, plus one still lives on the Setting page.
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
            userName: user?.nama,
            actions: actions,
            showMenuButton: !isRail,
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

  static Future<void> _logout() async {
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
  final String? userName;
  final List<Widget>? actions;
  final bool showMenuButton;

  const _GlassAppBar({
    required this.title,
    required this.showMenuButton,
    this.userName,
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
              if (userName != null && userName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.salmonGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _initials(userName!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 140),
                        child: Text(
                          userName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ...?actions,
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(2).toList();
    if (words.isEmpty) return '?';
    return words.map((w) => w[0].toUpperCase()).join();
  }
}

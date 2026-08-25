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
export 'app_text_field.dart' show AppHeaderSearchField;

/// REPLACES `app_scaffold.dart` 1:1 — same class name `AppScaffold`, same
/// constructor (`title`, `currentRoute`, `body`, `actions`). Wraps every
/// page body in [GlassBackground] and renders a translucent app bar, so
/// every screen using `AppScaffold` automatically gets the Glassmorphic
/// Zen canvas + blobs.
///
/// UI ENHANCEMENT:
/// - The top app bar header box vertically centers all its elements perfectly
///   (title, user badge, and header action '+' buttons) between the top and bottom edge.
/// - Added [AppGlassActionButton] for standardized frosted glassmorphic header actions.
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
          preferredSize: const Size.fromHeight(66),
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
        body: Padding(
          padding: const EdgeInsets.only(top: 66),
          child: body,
        ),
      );
    });

    return GlassBackground(
      child: isRail
          ? Row(
              children: [
                AppSidebar(items: items, currentRoute: currentRoute, onLogout: _logout),
                Expanded(child: content),
              ],
            )
          : content,
    );
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

/// Frosted Glassmorphic action button specifically calibrated to sit
/// directly in the vertical center of the header bar.
class AppGlassActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool primary;

  const AppGlassActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: primary ? AppColors.salmonGradient : null,
        color: primary ? null : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary ? Colors.transparent : AppColors.glassBorder(opacity: 0.7),
          width: 1.2,
        ),
        boxShadow: primary ? AppColors.shadowSalmon : AppColors.shadowSm,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        icon: Icon(icon, color: primary ? Colors.white : AppColors.ink, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: GlassPanel(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          blurSigma: AppColors.blurSigmaLight,
          shadow: AppColors.shadowSm,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showMenuButton)
                Builder(
                  builder: (ctx) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: const Icon(Icons.menu_rounded, color: AppColors.ink, size: 22),
                    tooltip: 'Menu',
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                )
              else
                const SizedBox(width: 4),
              Text(
                title, 
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (userName != null && userName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.salmonGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.shadowSalmon,
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
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          userName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: actions!,
                ),
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


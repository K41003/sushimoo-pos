import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/routes/app_routes.dart';
import '../../app/services/auth_service.dart';
import 'app_sidebar.dart';
import 'glass_panel.dart';
import '../../shared/utils/responsive.dart' show Responsive, DeviceClass;
import 'nav_item_factory.dart';
export 'app_text_field.dart' show AppHeaderSearchField;

/// REPLACES `app_scaffold.dart` 1:1 — same class name `AppScaffold`, same
/// constructor (`title`, `currentRoute`, `body`, `actions`). Wraps every
/// page body in [GlassBackground] and renders a translucent app bar, so
/// every screen using `AppScaffold` automatically gets the Glassmorphic
/// Zen canvas + blobs.
///
/// =====================================================================
/// REVERTED: search field no longer lives in/below the app bar.
/// =====================================================================
/// An earlier pass tried moving a page's search field into the app bar
/// area (`actions`, then a dedicated `searchField` param rendering a row
/// below the bar). That required `Scaffold.appBar`'s `PreferredSize` to
/// know the bar's exact pixel height ahead of layout — several
/// hand-calculated numbers were tried (66, 68, a forced 44, a forced 48
/// with headroom, finally an unconstrained `OverflowBox`) and every one
/// either still overflowed by a few px on a real device or, in the
/// `OverflowBox` case, produced an actual `Infinity` height and made the
/// app bar disappear entirely — `PreferredSize`'s contract fundamentally
/// needs a real finite number, which conflicts with letting content
/// size itself dynamically.
///
/// Per explicit product direction: search belongs in the page BODY, not
/// the app bar. `AppScaffold` no longer has any search-related param or
/// logic at all — it's back to exactly what it was before that attempt
/// (`title`/`currentRoute`/`body`/`actions`/`showBackButton`/
/// `onBackPressed`). Category/Ingredient/Product/Stock pages now render
/// their own `AppHeaderSearchField` as an ordinary widget at the top of
/// their own `body`, which has no special height contract to guess at —
/// it's just however tall the widget naturally is, like everything else
/// in a scrollable body.
class AppScaffold extends StatelessWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser;
    final items = navItemsForRole(user?.roleName ?? '');
    // CORRECTION: `Responsive.isLandscapeTablet` no longer exists — the
    // app now locks device orientation at startup (phone=portrait,
    // tablet=landscape always, see responsive.dart), so a tablet being
    // "in portrait" is no longer a real state to check for. `isRail`
    // (side nav rail vs drawer) is now just "is this a tablet at all".
    final isRail = Responsive.classOf(context) == DeviceClass.tablet;

    final content = Builder(builder: (scaffoldContext) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(_GlassAppBar.totalHeight),
          child: _GlassAppBar(
            title: title,
            userName: user?.nama,
            actions: actions,
            // Back button takes priority over the hamburger menu
            // when both would otherwise apply — a screen that needs
            // a back action (like Payment) is by definition a step
            // INSIDE a flow, not a top-level destination that also
            // needs drawer nav visible.
            showMenuButton: !isRail && !showBackButton,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed ?? () => Get.back(),
          ),
        ),
        drawer: (isRail || showBackButton)
            ? null
            : AppDrawer(items: items, currentRoute: currentRoute, onLogout: _logout),
        body: Padding(
          padding: const EdgeInsets.only(top: _GlassAppBar.totalHeight),
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
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const _GlassAppBar({
    required this.title,
    required this.showMenuButton,
    this.userName,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  });

  // Budgeted content height for `PreferredSize` (used by
  // `AppScaffold.build()` to reserve space for this bar before it's
  // actually laid out — `Scaffold.appBar` requires a size decided ahead
  // of time). Does not force the bar's actual rendered height — the Row
  // below is left completely unconstrained (see `build()`), so this
  // number only affects how much space `Scaffold` reserves in its
  // layout, not what the bar is allowed to render at.
  static const double contentHeight = 48.0;
  static const double verticalPadding = 24.0; // Padding 6+6 + GlassPanel 6+6
  static const double totalHeight = contentHeight + verticalPadding;

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
          // No SizedBox/OverflowBox forcing a height here — a prior
          // attempt to guess-and-force this (66 -> 68 -> exact-44 ->
          // 48-with-headroom -> unconstrained-OverflowBox) ended with
          // OverflowBox(maxHeight: infinity) making `PreferredSize`
          // receive an actual Infinity height, which made the whole app
          // bar disappear. The Row below is left to size itself
          // naturally with no ceiling or floor imposed on it at all —
          // exactly what it did before any of those attempts, which
          // never itself caused an overflow (the search field that used
          // to live in `actions` did; it's been moved to page bodies
          // instead, see category_page.dart etc).
          child: LayoutBuilder(
            builder: (context, constraints) {
              // FIX (header overflow on phones, e.g. Category page with
              // a search field + add button in `actions`): the row used
              // to always reserve space for the full username text next
              // to the avatar, with no upper bound on how much room
              // title + actions could also claim. On a ~360-400px-wide
              // phone screen, hamburger/back (44) + title + avatar+name
              // (up to ~130) + a fixed-width search field (commonly
              // 170-180) + an add button (36) routinely add up to more
              // than the available width, so the row overflowed and
              // Flutter rendered the yellow/black "overflowed" stripes
              // instead of clipping gracefully.
              //
              // Below this threshold the username text is dropped
              // (avatar alone still shows who's logged in at a glance)
              // and the title gets a `Flexible` + ellipsis so it can
              // never single-handedly force an overflow either. Above
              // the threshold (tablets, wide phones) behavior is
              // unchanged from before.
              final showUserName = constraints.maxWidth >= 480;

              return SizedBox(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left section: leading nav button + title
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (showBackButton)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink, size: 22),
                              tooltip: 'Back',
                              onPressed: onBackPressed,
                            )
                          else if (showMenuButton)
                            Builder(
                              builder: (ctx) => IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                icon: const Icon(Icons.menu_rounded, color: AppColors.ink, size: 22),
                                tooltip: 'Menu',
                                onPressed: () => Scaffold.of(ctx).openDrawer(),
                              ),
                            )
                          else
                            const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Trailing section: Avatar + Username (if tablet) + Action Buttons
                    // Rendered as an un-flexed group, while the left section is
                    // Expanded, ensuring this trailing group is pushed flush to the
                    // right edge on both tablet and phone.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (userName != null && userName!.isNotEmpty)
                          Row(
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
                              if (showUserName) ...[
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        if (actions != null && actions!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: actions!,
                          ),
                      ],
                    ),
                  ],
                ),
              );
              },
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

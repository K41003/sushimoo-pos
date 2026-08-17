import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/constants/colors.dart';
import '../../app/constants/dimensions.dart';
import 'glass_panel.dart';

/// REPLACES `app_sidebar.dart` 1:1 — same `NavItem` class + same
/// `AppSidebar`/`AppDrawer` constructors (`items`, `currentRoute`,
/// `onLogout`).
class NavItem {
  final String label;
  final IconData icon;
  final String route;
  const NavItem(this.label, this.icon, this.route);
}

/// Glass rail: frosted background, hairline right border, active item
/// marked with a salmon-tinted glass pill instead of a flat fill.
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
    return Container(
      width: AppDimensions.railWidth,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: Border(right: BorderSide(color: AppColors.glassBorder(opacity: 0.6))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.salmonGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.shadowSalmon,
            ),
            child: const Icon(Icons.restaurant_menu, size: 20, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              children: items.map((item) {
                final active = item.route == currentRoute;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: InkWell(
                    onTap: () => _navigate(context, item.route),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? Colors.white.withValues(alpha: 0.65) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: active
                            ? Border.all(color: AppColors.glassBorder(opacity: 0.7), width: 1.2)
                            : null,
                        boxShadow: active ? AppColors.shadowSm : null,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            item.icon,
                            size: 22,
                            color: active ? AppColors.salmon : AppColors.inkFaint,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? AppColors.salmon : AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (onLogout != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GlassIconButton(icon: Icons.logout, color: AppColors.danger, onPressed: onLogout),
            ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    if (route != currentRoute) Get.offAllNamed(route);
  }
}

/// Frosted drawer for portrait/tablet — same API as before.
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
      backgroundColor: Colors.transparent,
      child: GlassBackground(
        showBlobs: false,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Text('SUSHIMOO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            ),
            ...items.map((item) {
              final active = item.route == currentRoute;
              return ListTile(
                leading: Icon(item.icon, color: active ? AppColors.salmon : AppColors.inkMuted),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
                selected: active,
                selectedTileColor: Colors.white.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      ),
    );
  }
}

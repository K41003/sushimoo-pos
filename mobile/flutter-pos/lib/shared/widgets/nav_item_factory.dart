import 'package:flutter/material.dart';
import '../../app/constants/strings.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/widgets/app_sidebar.dart';

/// Builds role-aware navigation items (Admin vs Kasir) used by the shell.
List<NavItem> navItemsForRole(String role) {
  final admin = [
    const NavItem(AppStrings.dashboard, Icons.dashboard, AppRoutes.dashboard),
    const NavItem(AppStrings.category, Icons.category, AppRoutes.category),
    const NavItem(AppStrings.product, Icons.fastfood, AppRoutes.product),
    const NavItem(AppStrings.ingredient, Icons.kitchen, AppRoutes.ingredient),
    const NavItem(AppStrings.stock, Icons.inventory, AppRoutes.stock),
    const NavItem(AppStrings.table, Icons.table_bar, AppRoutes.table),
    const NavItem(AppStrings.report, Icons.bar_chart, AppRoutes.report),
    const NavItem(AppStrings.closing, Icons.lock_clock, AppRoutes.closing),
    const NavItem(AppStrings.setting, Icons.settings, AppRoutes.setting),
  ];
  final kasir = [
    const NavItem(AppStrings.dashboard, Icons.dashboard, AppRoutes.dashboard),
    const NavItem(AppStrings.shift, Icons.schedule, AppRoutes.shift),
    const NavItem(AppStrings.pos, Icons.point_of_sale, AppRoutes.pos),
    const NavItem(AppStrings.expense, Icons.money_off, AppRoutes.expense),
    const NavItem(AppStrings.report, Icons.bar_chart, AppRoutes.report),
    const NavItem(AppStrings.closing, Icons.lock_clock, AppRoutes.closing),
    const NavItem(AppStrings.setting, Icons.settings, AppRoutes.setting),
  ];
  return role == AppRoles.admin ? admin : kasir;
}

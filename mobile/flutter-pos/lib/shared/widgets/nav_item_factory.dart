import 'package:flutter/material.dart';
import '../../app/routes/app_routes.dart';
import '../../shared/widgets/app_sidebar.dart';

/// Builds role-aware navigation items (Admin vs Kasir) used by the shell.
List<NavItem> navItemsForRole(String role) {
  final admin = [
    const NavItem('Dashboard', Icons.dashboard, AppRoutes.dashboard),
    const NavItem('Category', Icons.category, AppRoutes.category),
    const NavItem('Product', Icons.fastfood, AppRoutes.product),
    const NavItem('Ingredient', Icons.kitchen, AppRoutes.ingredient),
    const NavItem('Stock', Icons.inventory, AppRoutes.stock),
    const NavItem('Table', Icons.table_bar, AppRoutes.table),
    const NavItem('Report', Icons.bar_chart, AppRoutes.report),
    const NavItem('Closing', Icons.lock_clock, AppRoutes.closing),
    const NavItem('Setting', Icons.settings, AppRoutes.setting),
  ];
  final kasir = [
    const NavItem('Dashboard', Icons.dashboard, AppRoutes.dashboard),
    const NavItem('Shift', Icons.schedule, AppRoutes.shift),
    const NavItem('POS', Icons.point_of_sale, AppRoutes.pos),
    const NavItem('Expense', Icons.money_off, AppRoutes.expense),
    const NavItem('Report', Icons.bar_chart, AppRoutes.report),
    const NavItem('Closing', Icons.lock_clock, AppRoutes.closing),
    const NavItem('Setting', Icons.settings, AppRoutes.setting),
  ];
  return role == 'Admin' ? admin : kasir;
}

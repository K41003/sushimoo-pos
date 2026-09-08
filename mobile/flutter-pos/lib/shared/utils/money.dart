/// Single source of truth for "Rp <amount>" formatting.
///
/// REFACTOR NOTE: this exact formatting logic — `'Rp ${x.toStringAsFixed(0)}'`
/// with a non-num fallback to 0 — previously existed as near-identical
/// copies in several places:
///   - `money()`      in modules/product/widgets/product_card_widget.dart
///   - `money()`      in modules/product/controllers/product_controller.dart
///   - `moneyShort()` in modules/pos/widgets/pos_product_tile.dart
///   - inline `_money()` closures in dashboard_page.dart, receipt_page.dart,
///     pos_page.dart
///   - repeated inline string interpolation in report_page.dart,
///     payment_page.dart, closing_page.dart, expense_page.dart,
///     cart_tile.dart, shift_page.dart
///
/// `formatRupiah` preserves the exact behavior of every one of those
/// (same "Rp " prefix, same 0-decimal formatting, same non-num guard) so
/// consolidating call sites onto it changes zero visible output.
///
/// Old free functions (`money`, `moneyShort`) are kept as thin deprecated
/// wrappers delegating here rather than removed outright, so any call
/// site not touched in this pass keeps compiling unchanged.
String formatRupiah(dynamic value) {
  final num safeValue = value is num ? value : 0;
  return 'Rp ${safeValue.toStringAsFixed(0)}';
}

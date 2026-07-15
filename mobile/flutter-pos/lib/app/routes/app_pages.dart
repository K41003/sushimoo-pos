import 'package:get/get.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_page.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_page.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_page.dart';
import '../../modules/category/bindings/category_binding.dart';
import '../../modules/category/views/category_page.dart';
import '../../modules/product/bindings/product_binding.dart';
import '../../modules/product/views/product_page.dart';
import '../../modules/ingredient/bindings/ingredient_binding.dart';
import '../../modules/ingredient/views/ingredient_page.dart';
import '../../modules/stock/bindings/stock_binding.dart';
import '../../modules/stock/views/stock_page.dart';
import '../../modules/table/bindings/table_binding.dart';
import '../../modules/table/views/table_page.dart';
import '../../modules/shift/bindings/shift_binding.dart';
import '../../modules/shift/views/shift_page.dart';
import '../../modules/pos/bindings/pos_binding.dart';
import '../../modules/pos/views/pos_page.dart';
import '../../modules/payment/bindings/payment_binding.dart';
import '../../modules/payment/views/payment_page.dart';
import '../../modules/receipt/bindings/receipt_binding.dart';
import '../../modules/receipt/views/receipt_page.dart';
import '../../modules/expense/bindings/expense_binding.dart';
import '../../modules/expense/views/expense_page.dart';
import '../../modules/report/bindings/report_binding.dart';
import '../../modules/report/views/report_page.dart';
import '../../modules/closing/bindings/closing_binding.dart';
import '../../modules/closing/views/closing_page.dart';
import '../../modules/setting/bindings/setting_binding.dart';
import '../../modules/setting/views/setting_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryPage(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.product,
      page: () => const ProductPage(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.ingredient,
      page: () => const IngredientPage(),
      binding: IngredientBinding(),
    ),
    GetPage(
      name: AppRoutes.stock,
      page: () => const StockPage(),
      binding: StockBinding(),
    ),
    GetPage(
      name: AppRoutes.table,
      page: () => const TablePage(),
      binding: TableBinding(),
    ),
    GetPage(
      name: AppRoutes.shift,
      page: () => const ShiftPage(),
      binding: ShiftBinding(),
    ),
    GetPage(
      name: AppRoutes.pos,
      page: () => const PosPage(),
      binding: PosBinding(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentPage(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.receipt,
      page: () => const ReceiptPage(),
      binding: ReceiptBinding(),
    ),
    GetPage(
      name: AppRoutes.expense,
      page: () => const ExpensePage(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.report,
      page: () => const ReportPage(),
      binding: ReportBinding(),
    ),
    GetPage(
      name: AppRoutes.closing,
      page: () => const ClosingPage(),
      binding: ClosingBinding(),
    ),
    GetPage(
      name: AppRoutes.setting,
      page: () => const SettingPage(),
      binding: SettingBinding(),
    ),
  ];
}

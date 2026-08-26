// test/shared/widgets/app_scaffold_test.dart
//
// Widget tests for [AppScaffold].
//
// Focus:
//   - Regression coverage for the role/menu-source bug that was fixed:
//     AppScaffold must derive the sidebar/drawer items from
//     `AuthService.to.currentUser` (NOT `StorageService.to.user`), so an
//     Admin login always shows the Admin menu and a Kasir login always
//     shows the Kasir menu.
//   - Portrait/narrow layout -> hamburger + Drawer.
//   - Landscape tablet layout -> persistent AppSidebar rail (no drawer).
//   - Logout button triggers `AuthService.to.logout()` and navigates to
//     the login route.
//
// Run:
//   flutter pub get
//   flutter test test/shared/widgets/app_scaffold_test.dart
//
// Notes:
//   - `AuthService` is mocked with Mockito. `StorageService` is also
//     registered (with a mock) purely to prove the fix: it is stubbed to
//     return a DIFFERENT (wrong) role than AuthService, and the test
//     asserts the UI follows AuthService, not StorageService.
//   - `EasyLoading` calls inside `_logout()`'s catch block require the
//     EasyLoading builder; since our happy-path logout doesn't throw, we
//     don't need EasyLoading.init() for these tests, but we still wrap
//     with GetMaterialApp for navigation.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sushimoo_pos/app/routes/app_routes.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/storage_service.dart';
import 'package:sushimoo_pos/data/models/role.dart';
import 'package:sushimoo_pos/data/models/user.dart';
import 'package:sushimoo_pos/data/response/api_response.dart';
import 'package:sushimoo_pos/shared/widgets/app_scaffold.dart';

import 'app_scaffold_test.mocks.dart';

@GenerateMocks([AuthService, StorageService])
void main() {
  late MockAuthService mockAuthService;
  late MockStorageService mockStorageService;

  final adminUser = User(
    idUser: 1,
    idRole: 1,
    nama: 'Budi Admin',
    username: 'admin',
    status: true,
    role: const Role(idRole: 1, namaRole: 'Admin'),
  );

  final kasirUser = User(
    idUser: 2,
    idRole: 2,
    nama: 'Sari Kasir',
    username: 'kasir',
    status: true,
    role: const Role(idRole: 2, namaRole: 'Kasir'),
  );

  setUp(() {
    Get.testMode = true;
    mockAuthService = MockAuthService();
    mockStorageService = MockStorageService();

    if (Get.isRegistered<AuthService>()) Get.delete<AuthService>();
    if (Get.isRegistered<StorageService>()) Get.delete<StorageService>();
    Get.put<AuthService>(mockAuthService);
    Get.put<StorageService>(mockStorageService);

    when(mockAuthService.logout())
        .thenAnswer((_) async => const ApiResponse<void>(success: true, message: 'OK'));
  });

  tearDown(() => Get.reset());

  Widget wrap(Widget child, {Size size = const Size(400, 800)}) {
    return GetMaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
      getPages: [
        GetPage(name: AppRoutes.login, page: () => const Text('Login Page')),
      ],
    );
  }

  group('AppScaffold - role-based navigation (regression: source of truth)', () {
    testWidgets('shows Admin menu items when AuthService.currentUser is Admin, '
        'even if StorageService has a different/stale role (portrait/drawer)',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);
      // Deliberately wrong/stale value to prove AppScaffold does NOT use it.
      when(mockStorageService.user).thenReturn(kasirUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
        size: const Size(400, 800), // portrait phone -> uses Drawer
      ));
      await tester.pumpAndSettle();

      // Open the drawer via the hamburger button.
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Product'), findsOneWidget);
      expect(find.text('Ingredient'), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Table'), findsOneWidget);

      // Kasir-only items must NOT appear for an Admin.
      expect(find.text('Shift'), findsNothing);
      expect(find.text('Expense'), findsNothing);
    });

    testWidgets('shows Kasir menu items when AuthService.currentUser is Kasir',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(kasirUser);
      when(mockStorageService.user).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
        size: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('POS'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);

      // Admin-only items must NOT appear for a Kasir.
      expect(find.text('Category'), findsNothing);
      expect(find.text('Product'), findsNothing);
    });

    testWidgets('falls back to Kasir menu (edge case) when currentUser is null',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
        size: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      // navItemsForRole('') falls through to the kasir branch.
      expect(find.text('Shift'), findsOneWidget);
      expect(find.text('Category'), findsNothing);
    });
  });

  group('AppScaffold - responsive layout', () {
    testWidgets('renders a persistent AppSidebar rail (no hamburger) on landscape tablet',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
        size: const Size(1280, 800), // landscape tablet -> rail
      ));
      await tester.pumpAndSettle();

      // Rail renders nav labels directly, no need to open a drawer.
      expect(find.text('Category'), findsOneWidget);
      // No hamburger menu button expected on the rail layout.
      expect(find.byIcon(Icons.menu_rounded), findsNothing);
    });

    testWidgets('renders hamburger + Drawer on narrow/portrait layout', (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
        size: const Size(400, 800),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      // Drawer content not visible until opened.
      expect(find.text('Category'), findsNothing);
    });
  });

  group('AppScaffold - logout flow', () {
    testWidgets('tapping logout calls AuthService.logout() and navigates to login (happy path)',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      verify(mockAuthService.logout()).called(1);
      expect(Get.currentRoute, AppRoutes.login);
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('shows an error toast/snackbar path gracefully when logout throws (edge case)',
        (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);
      when(mockAuthService.logout()).thenThrow(Exception('network error'));

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      // Should not throw/crash the widget tree even though logout() throws.
      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      // Navigation to login should NOT have happened since logout failed
      // before reaching Get.offAllNamed.
      expect(Get.currentRoute, isNot(AppRoutes.login));
    });
  });

  group('AppScaffold - basic content rendering', () {
    testWidgets('renders title, body, and provided actions', (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        AppScaffold(
          title: 'Custom Title',
          currentRoute: AppRoutes.dashboard,
          body: const Text('Body Content'),
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows the logged-in user name in the app bar', (tester) async {
      when(mockAuthService.currentUser).thenReturn(adminUser);

      await tester.pumpWidget(wrap(
        const AppScaffold(
          title: 'Dashboard',
          currentRoute: AppRoutes.dashboard,
          body: SizedBox.shrink(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Budi Admin'), findsOneWidget);
    });
  });
}

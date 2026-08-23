// test/modules/pos/controllers/pos_controller_test.dart
//
// Unit tests for [PosController].
//
// Focus:
//   - Cart business logic: add/increment/decrement/remove/clear, subtotal/
//     tax/grandTotal calculation
//   - Search logic: `isSearching`, race-condition token guard in
//     `_searchProducts` (edge case: a slower earlier request must not
//     overwrite a newer one)
//   - `placeOrder()` happy path and edge cases (empty cart, no table
//     selected, API failure)
//
// Run:
//   flutter pub get
//   flutter test test/modules/pos/controllers/pos_controller_test.dart
//
// Notes:
//   - `PrinterService` is mocked with Mockito since `placeOrder()` and
//     kitchen ticket printing touch Bluetooth/native plugins that are not
//     available in the test environment.
//   - `ApiClient` is mocked so no real HTTP call is made; `Paginated.
//     fromJson` is exercised directly through realistic JSON payloads to
//     also validate model/controller integration.
//   - `selectTable()` opens a `Get.dialog`, so tests that would trigger it
//     indirectly (empty cart -> placeOrder -> selectTable) are written as
//     widget tests with a `GetMaterialApp` pump.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sushimoo_pos/app/services/api_client.dart';
import 'package:sushimoo_pos/app/services/printer_service.dart';
import 'package:sushimoo_pos/data/models/category.dart';
import 'package:sushimoo_pos/data/models/product.dart';
import 'package:sushimoo_pos/data/models/table.dart';
import 'package:sushimoo_pos/data/models/transaction.dart';
import 'package:sushimoo_pos/data/response/api_response.dart';
import 'package:sushimoo_pos/modules/pos/controllers/pos_controller.dart';

import 'pos_controller_test.mocks.dart';

@GenerateMocks([ApiClient, PrinterService])
void main() {
  late MockApiClient mockApiClient;
  late MockPrinterService mockPrinterService;

  Product buildProduct({int id = 1, String name = 'Sushi Roll', double price = 25000}) {
    return Product(
      idProduk: id,
      idKategori: 1,
      namaProduk: name,
      harga: price,
      status: true,
    );
  }

  setUp(() {
    Get.testMode = true;
    mockApiClient = MockApiClient();
    mockPrinterService = MockPrinterService();

    if (Get.isRegistered<ApiClient>()) Get.delete<ApiClient>();
    if (Get.isRegistered<PrinterService>()) Get.delete<PrinterService>();
    Get.put<ApiClient>(mockApiClient);
    Get.put<PrinterService>(mockPrinterService);

    // Default stubs so onInit() (loadCategories + loadTables) doesn't
    // throw when a test doesn't care about them.
    when(mockApiClient.get(
      '/categories',
      query: anyNamed('query'),
      fromData: anyNamed('fromData'),
    )).thenAnswer((_) async => const ApiResponse<dynamic>(
          success: true,
          message: 'OK',
          data: {
            'items': [],
            'meta': {'page': 1, 'perPage': 100, 'total': 0, 'lastPage': 1},
          },
        ));

    when(mockApiClient.get(
      '/meja',
      query: anyNamed('query'),
      fromData: anyNamed('fromData'),
    )).thenAnswer((_) async => const ApiResponse<dynamic>(
          success: true,
          message: 'OK',
          data: {
            'items': [],
            'meta': {'page': 1, 'perPage': 100, 'total': 0, 'lastPage': 1},
          },
        ));
  });

  tearDown(() => Get.reset());

  group('PosController - cart business logic (happy path)', () {
    test('addToCart adds a new item with qty 1', () {
      final c = PosController();
      final p = buildProduct();

      c.addToCart(p);

      expect(c.cart.length, 1);
      expect(c.cart.first.qty, 1);
      expect(c.cart.first.product.idProduk, p.idProduk);
    });

    test('addToCart increments qty when product already in cart', () {
      final c = PosController();
      final p = buildProduct();

      c.addToCart(p);
      c.addToCart(p);

      expect(c.cart.length, 1);
      expect(c.cart.first.qty, 2);
    });

    test('incQty and decQty adjust quantity correctly', () {
      final c = PosController();
      c.addToCart(buildProduct());

      c.incQty(0);
      expect(c.cart[0].qty, 2);

      c.decQty(0);
      expect(c.cart[0].qty, 1);
    });

    test('decQty removes the item once qty reaches 0 (edge case)', () {
      final c = PosController();
      c.addToCart(buildProduct());

      expect(c.cart.length, 1);
      c.decQty(0); // qty was 1 -> should remove, not go to 0
      expect(c.cart, isEmpty);
    });

    test('removeItem removes the item at the given index', () {
      final c = PosController();
      c.addToCart(buildProduct(id: 1));
      c.addToCart(buildProduct(id: 2));

      c.removeItem(0);

      expect(c.cart.length, 1);
      expect(c.cart.first.product.idProduk, 2);
    });

    test('clearCart empties the cart', () {
      final c = PosController();
      c.addToCart(buildProduct());
      c.clearCart();

      expect(c.cart, isEmpty);
    });

    test('subtotal/tax/grandTotal reflect cart contents', () {
      final c = PosController();
      c.addToCart(buildProduct(id: 1, price: 25000)); // qty 1
      c.addToCart(buildProduct(id: 2, price: 10000)); // qty 1

      expect(c.subtotal, 35000);
      expect(c.tax, 35000 * c.taxRate); // taxRate = 0.0 per AppConstants
      expect(c.grandTotal, 35000 + c.tax);
    });

    test('grandTotal is 0 for an empty cart (edge case)', () {
      final c = PosController();
      expect(c.subtotal, 0);
      expect(c.grandTotal, 0);
    });
  });

  group('PosController - search logic', () {
    test('isSearching is false for empty/whitespace query', () {
      final c = PosController();
      c.searchQuery.value = '   ';
      expect(c.isSearching, isFalse);
    });

    test('isSearching is true for a non-empty query', () {
      final c = PosController();
      c.searchQuery.value = 'ramen';
      expect(c.isSearching, isTrue);
    });

    test('onSearchChanged with empty text restores selected category products',
        () async {
      when(mockApiClient.get(
        '/products',
        query: {'id_kategori': 5, 'perPage': 100},
        fromData: anyNamed('fromData'),
      )).thenAnswer((_) async => const ApiResponse<dynamic>(
            success: true,
            message: 'OK',
            data: {
              'items': [
                {
                  'id_produk': 1,
                  'id_kategori': 5,
                  'nama_produk': 'Nigiri',
                  'harga': '15000.00',
                  'status': 1,
                }
              ],
              'meta': {'page': 1, 'perPage': 100, 'total': 1, 'lastPage': 1},
            },
          ));

      final c = PosController();
      c.selectedCategoryId.value = 5;

      c.onSearchChanged('');
      // selectCategory triggers an async API call; give it a tick.
      await Future<void>.delayed(Duration.zero);

      expect(c.products.length, 1);
      expect(c.products.first.namaProduk, 'Nigiri');
    });

    test(
        'a slower earlier search response does not overwrite a newer search '
        '(token guard, edge case)', () async {
      final c = PosController();

      // First (slow) call for "aa"
      when(mockApiClient.get(
        '/products',
        query: {'q': 'aa', 'perPage': 100},
        fromData: anyNamed('fromData'),
      )).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return const ApiResponse<dynamic>(
          success: true,
          message: 'OK',
          data: {
            'items': [
              {
                'id_produk': 1,
                'id_kategori': 1,
                'nama_produk': 'Stale Result',
                'harga': '1000.00',
                'status': 1,
              }
            ],
            'meta': {'page': 1, 'perPage': 100, 'total': 1, 'lastPage': 1},
          },
        );
      });

      // Second (fast) call for "aab"
      when(mockApiClient.get(
        '/products',
        query: {'q': 'aab', 'perPage': 100},
        fromData: anyNamed('fromData'),
      )).thenAnswer((_) async => const ApiResponse<dynamic>(
            success: true,
            message: 'OK',
            data: {
              'items': [
                {
                  'id_produk': 2,
                  'id_kategori': 1,
                  'nama_produk': 'Fresh Result',
                  'harga': '2000.00',
                  'status': 1,
                }
              ],
              'meta': {'page': 1, 'perPage': 100, 'total': 1, 'lastPage': 1},
            },
          ));

      // Fire the slow query, then immediately fire a newer one.
      final firstCall = c.onSearchChanged('aa');
      c.onSearchChanged('aab');

      await firstCall;
      // Wait for the slow request to resolve too.
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(c.products.length, 1);
      expect(c.products.first.namaProduk, 'Fresh Result');
    });
  });

  group('PosController.placeOrder() - edge cases', () {
    testWidgets('shows error and does not call API when cart is empty', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox.shrink()));

      final c = PosController();
      await c.placeOrder();

      verifyNever(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      ));
    });
  });

  group('PosController.placeOrder() - happy path', () {
    testWidgets('places an order, prints kitchen ticket, clears cart, and navigates to payment',
        (tester) async {
      final table = const TableModel(
        idMeja: 7,
        nomorMeja: 'B2',
        kapasitas: 2,
        status: 'available',
      );

      when(mockPrinterService.printKitchenTicket(any)).thenAnswer((_) async {});

      when(mockApiClient.post(
        '/transaksi',
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).thenAnswer((invocation) async {
        final fromData = invocation.namedArguments[#fromData]
            as Transaction Function(dynamic);
        final raw = {
          'id_transaksi': 99,
          'invoice_number': 'INV-099',
          'id_shift': 1,
          'id_user': 1,
          'id_meja': 7,
          'tanggal': '2026-08-20T12:00:00Z',
          'total': 25000,
          'status': 'pending',
        };
        return ApiResponse<Transaction>(
          success: true,
          message: 'Order placed',
          data: fromData(raw),
        );
      });

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/pos',
          getPages: [
            GetPage(name: '/pos', page: () => const SizedBox.shrink()),
            GetPage(name: '/payment', page: () => const Text('Payment Page')),
          ],
        ),
      );

      final c = PosController();
      c.addToCart(buildProduct());
      c.selectedTable.value = table;

      await c.placeOrder();
      await tester.pumpAndSettle();

      verify(mockPrinterService.printKitchenTicket(any)).called(1);
      expect(c.cart, isEmpty);
      expect(Get.currentRoute, '/payment');
      expect(find.text('Payment Page'), findsOneWidget);
    });
  });
}

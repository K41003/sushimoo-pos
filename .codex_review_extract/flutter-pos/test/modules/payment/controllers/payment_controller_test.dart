// test/modules/payment/controllers/payment_controller_test.dart
//
// Unit tests for [PaymentController].
//
// Focus:
//   - Business logic: `change`, `isCash`, reactive `receivedText` mirroring
//   - State management: `loading`, `selectedMethod`
//   - `pay()` happy path (success + navigation) and edge cases
//     (no method selected, insufficient cash amount, API failure)
//
// Run:
//   flutter pub get
//   flutter test test/modules/payment/controllers/payment_controller_test.dart
//
// Notes:
//   - GetX (`Get.offAndToNamed`, `EasyLoading.show/dismiss`) requires a
//     widget/navigator context in real usage. For pure controller unit
//     tests we avoid triggering real navigation/EasyLoading side effects
//     by testing the failure path (which does NOT call
//     `Get.offAndToNamed`) directly, and by wrapping the happy-path
//     navigation assertion in a `GetMaterialApp` pump so `Get` has a
//     valid context. See `payment_controller_navigation_test.dart`
//     widget test group below for that scenario.
//   - `ApiClient` is mocked with Mockito so no real HTTP call is made.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sushimoo_pos/app/services/api_client.dart';
import 'package:sushimoo_pos/data/models/payment.dart';
import 'package:sushimoo_pos/data/models/table.dart';
import 'package:sushimoo_pos/data/models/transaction.dart';
import 'package:sushimoo_pos/data/response/api_response.dart';
import 'package:sushimoo_pos/modules/payment/controllers/payment_controller.dart';

import 'payment_controller_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late MockApiClient mockApiClient;
  late Transaction transaction;

  setUp(() {
    mockApiClient = MockApiClient();

    // Register the mocked ApiClient so `ApiClient.to` (used internally by
    // PaymentController via `ApiClient.to`) resolves to our mock instead
    // of constructing a real Dio-backed client.
    Get.testMode = true;
    if (Get.isRegistered<ApiClient>()) {
      Get.delete<ApiClient>();
    }
    Get.put<ApiClient>(mockApiClient);

    transaction = const Transaction(
      idTransaksi: 1,
      invoiceNumber: 'INV-001',
      idShift: 1,
      idUser: 1,
      idMeja: 1,
      tanggal: '2026-08-20T10:00:00Z',
      total: 100000,
      status: 'pending',
      table: TableModel(
        idMeja: 1,
        nomorMeja: 'A1',
        kapasitas: 4,
        status: 'occupied',
      ),
    );
  });

  tearDown(() {
    Get.reset();
  });

  PaymentController buildController() => PaymentController(transaction: transaction);

  group('PaymentController - initial state', () {
    test('selectedMethod starts as null and isCash is false', () {
      final c = buildController();
      c.onInit();

      expect(c.selectedMethod.value, isNull);
      expect(c.isCash, isFalse);
      expect(c.loading.value, isFalse);

      c.onClose();
    });

    test('change is 0 when receivedText is empty', () {
      final c = buildController();
      c.onInit();

      expect(c.change, 0);

      c.onClose();
    });
  });

  group('PaymentController - receivedText reactivity (happy path)', () {
    test('typing into receivedController mirrors into receivedText', () {
      final c = buildController();
      c.onInit();

      c.receivedController.text = '50000';
      // The listener added in onInit synchronously updates receivedText.
      expect(c.receivedText.value, '50000');

      c.onClose();
    });

    test('change is calculated correctly when amount received > total', () {
      final c = buildController();
      c.onInit();

      c.receivedController.text = '150000'; // total = 100000
      expect(c.change, 50000);

      c.onClose();
    });

    test('change is clamped to 0 when amount received < total (edge case)', () {
      final c = buildController();
      c.onInit();

      c.receivedController.text = '30000'; // total = 100000
      expect(c.change, 0); // clamp(0, infinity) prevents negative change

      c.onClose();
    });

    test('change is 0 when received text is not a valid number (edge case)', () {
      final c = buildController();
      c.onInit();

      c.receivedController.text = 'abc';
      expect(c.change, 0); // double.tryParse fails -> defaults to 0

      c.onClose();
    });
  });

  group('PaymentController - isCash', () {
    test('isCash is true only when selectedMethod == 1 (Cash)', () {
      final c = buildController();
      c.onInit();

      c.selectedMethod.value = 1;
      expect(c.isCash, isTrue);

      c.selectedMethod.value = 2; // QRIS
      expect(c.isCash, isFalse);

      c.selectedMethod.value = 3; // Debit
      expect(c.isCash, isFalse);

      c.onClose();
    });
  });

  group('PaymentController.pay() - edge cases (no navigation triggered)', () {
    test('shows error and does not call API when no method selected', () async {
      final c = buildController();
      c.onInit();

      await c.pay();

      verifyNever(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      ));
      expect(c.loading.value, isFalse);

      c.onClose();
    });

    test('shows error and does not call API when cash received < total', () async {
      final c = buildController();
      c.onInit();

      c.selectedMethod.value = 1; // Cash
      c.receivedController.text = '50000'; // less than total (100000)

      await c.pay();

      verifyNever(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      ));

      c.onClose();
    });

    test('body does not include uang_diterima for non-cash methods', () async {
      final c = buildController();
      c.onInit();

      c.selectedMethod.value = 2; // QRIS

      when(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#body] as Map<String, dynamic>;
        expect(body.containsKey('uang_diterima'), isFalse);
        expect(body['id_metode'], 2);
        return const ApiResponse<Payment>(success: false, message: 'network down');
      });

      await c.pay();

      verify(mockApiClient.post(
        '/transaksi/1/pembayaran',
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).called(1);

      c.onClose();
    });

    test('loading resets to false after API failure (edge case)', () async {
      final c = buildController();
      c.onInit();

      c.selectedMethod.value = 2;
      when(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).thenAnswer(
        (_) async => const ApiResponse<Payment>(success: false, message: 'Server error'),
      );

      await c.pay();

      expect(c.loading.value, isFalse);

      c.onClose();
    });
  });

  group('PaymentController.pay() - happy path (navigation)', () {
    testWidgets('successful cash payment calls API with correct payload and navigates to receipt',
        (tester) async {
      final payment = Payment.fromJson({
        'id_pembayaran': 10,
        'id_transaksi': 1,
        'id_metode': 1,
        'total_bayar': '100000.00',
        'uang_diterima': '150000.00',
        'kembalian': '50000.00',
        'status': 'paid',
      });

      when(mockApiClient.post(
        any,
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).thenAnswer((invocation) async {
        final body = invocation.namedArguments[#body] as Map<String, dynamic>;
        expect(body['id_metode'], 1);
        expect(body['uang_diterima'], 150000);
        return ApiResponse<Payment>(success: true, message: 'OK', data: payment);
      });

      final controller = buildController();

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/payment',
          getPages: [
            GetPage(name: '/payment', page: () => const SizedBox.shrink()),
            GetPage(name: '/receipt', page: () => const Text('Receipt Page')),
          ],
        ),
      );

      controller.onInit();
      controller.selectedMethod.value = 1;
      controller.receivedController.text = '150000';

      await controller.pay();
      await tester.pumpAndSettle();

      verify(mockApiClient.post(
        '/transaksi/1/pembayaran',
        body: anyNamed('body'),
        fromData: anyNamed('fromData'),
      )).called(1);

      expect(Get.currentRoute, '/receipt');
      expect(find.text('Receipt Page'), findsOneWidget);

      controller.onClose();
    });
  });
}

// test/app/services/auth_service_test.dart
//
// Regression tests for the intermittent forced-logout bug in
// AuthService.me(): it previously wrote an EMPTY STRING over the real
// auth token whenever StorageService.to.token was null at call time,
// because of the `token: StorageService.to.token ?? ''` fallback inside
// saveSession(). Since `/me` never returns a new token, me() should
// never write a blank one.
//
// Run with: flutter test test/app/services/auth_service_test.dart
//
// Dependencies used: mocktail, get (already implied by the GetX stack).
// Add to pubspec.yaml dev_dependencies if not present:
//   mocktail: ^1.0.0

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sushimoo_pos/app/services/api_client.dart';
import 'package:sushimoo_pos/app/services/auth_service.dart';
import 'package:sushimoo_pos/app/services/storage_service.dart';
import 'package:sushimoo_pos/data/models/role.dart';
import 'package:sushimoo_pos/data/models/user.dart';
import 'package:sushimoo_pos/data/response/api_response.dart';

class MockStorageService extends Mock implements StorageService {}

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockStorageService storage;
  late MockApiClient api;
  late AuthService authService;

  final fakeUser = User(
    idUser: 1,
    idRole: 1,
    nama: 'Administrator',
    username: 'admin',
    status: true,
    role: const Role(idRole: 1, namaRole: 'Admin'),
  );

  setUp(() {
    Get.reset();
    storage = MockStorageService();
    api = MockApiClient();
    Get.put<StorageService>(storage);
    Get.put<ApiClient>(api);
    authService = AuthService();

    registerFallbackValue(fakeUser);
  });

  group('AuthService.me() — token corruption regression', () {
    test(
      'REGRESSION: does NOT call saveSession with an empty token when '
      'StorageService.token is null',
      () async {
        when(() => storage.token).thenReturn(null);
        when(() => api.get<User>('/me', fromData: any(named: 'fromData')))
            .thenAnswer(
          (invocation) async {
            final fromData = invocation.namedArguments[#fromData]
                as User Function(dynamic);
            return ApiResponse<User>(
              success: true,
              message: '',
              data: fromData({
                'id_user': 1,
                'id_role': 1,
                'nama': 'Administrator',
                'username': 'admin',
                'status': true,
              }),
            );
          },
        );

        await authService.me();

        // The core assertion: saveSession must never be invoked with an
        // empty-string token. Before the fix, this WAS being called with
        // token: '' whenever storage.token was null.
        final captured = verify(
          () => storage.saveSession(
            token: captureAny(named: 'token'),
            user: captureAny(named: 'user'),
          ),
        ).captured;

        expect(
          captured.isEmpty,
          isTrue,
          reason:
              'saveSession should not be called at all when there is no '
              'existing token to preserve — calling it with an empty '
              'token silently corrupts the stored session.',
        );
      },
    );

    test('preserves the existing token when refreshing the profile', () async {
      when(() => storage.token).thenReturn('real-token-123');
      when(() => storage.saveSession(
            token: any(named: 'token'),
            user: any(named: 'user'),
          )).thenAnswer((_) async {});
      when(() => api.get<User>('/me', fromData: any(named: 'fromData')))
          .thenAnswer(
        (invocation) async {
          final fromData =
              invocation.namedArguments[#fromData] as User Function(dynamic);
          return ApiResponse<User>(
            success: true,
            message: '',
            data: fromData({
              'id_user': 1,
              'id_role': 1,
              'nama': 'Administrator',
              'username': 'admin',
              'status': true,
            }),
          );
        },
      );

      await authService.me();

      verify(() => storage.saveSession(
            token: 'real-token-123',
            user: any(named: 'user', that: isA<User>()),
          )).called(1);
    });

    test('does not call saveSession when the /me request fails', () async {
      when(() => storage.token).thenReturn('real-token-123');
      when(() => api.get<User>('/me', fromData: any(named: 'fromData')))
          .thenAnswer((_) async => const ApiResponse<User>(
                success: false,
                message: 'Unauthorized',
              ));

      await authService.me();

      verifyNever(() => storage.saveSession(
            token: any(named: 'token'),
            user: any(named: 'user'),
          ));
    });

    test('does not call saveSession when response.data is null despite success',
        () async {
      when(() => storage.token).thenReturn('real-token-123');
      when(() => api.get<User>('/me', fromData: any(named: 'fromData')))
          .thenAnswer((_) async => const ApiResponse<User>(
                success: true,
                message: '',
                data: null,
              ));

      await authService.me();

      verifyNever(() => storage.saveSession(
            token: any(named: 'token'),
            user: any(named: 'user'),
          ));
    });
  });
}

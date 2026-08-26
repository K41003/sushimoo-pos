import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sushimoo_pos/app/constants/app_constants.dart';
import 'package:sushimoo_pos/app/services/storage_service.dart';
import 'package:sushimoo_pos/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;

  setUp(() async {
    Get.testMode = true;
    tempDir = await Directory.systemTemp.createTemp('sushimoo_pos_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return tempDir.path;
    });
    await GetStorage.init(AppConstants.boxName);
    if (Get.isRegistered<StorageService>()) {
      await Get.delete<StorageService>(force: true);
    }
    Get.put(StorageService());
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    Get.reset();
  });

  testWidgets('app bootstraps with initial services', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}

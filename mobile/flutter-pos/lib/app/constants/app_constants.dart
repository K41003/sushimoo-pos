class AppConstants {
  AppConstants._();

  /// API base URL.
  ///
  /// Dev default points Android emulator to the host machine. For staging or
  /// production builds, pass:
  /// `--dart-define=API_BASE_URL=https://api.example.com/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2',
  );

  /// API port. Leave empty to use the default for the scheme (80 for http,
  /// 443 for https). Useful when backend runs on `php artisan serve` (8000).
  static const String apiPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '',
  );

  /// Enable fully local/demo mode without backend.
  ///
  /// Use: `flutter run --dart-define=LOCAL_MODE=true`
  static const bool localMode = bool.fromEnvironment(
    'LOCAL_MODE',
    defaultValue: false,
  );

  /// Optional host override for local virtual-host setups only.
  ///
  /// Leave empty in normal staging/production builds.
  static const String apiHostHeader = String.fromEnvironment(
    'API_HOST_HEADER',
    defaultValue: 'laravel-api.test',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Tax rate applied to subtotal for the POS grand total.
  static const double taxRate = 0.0;

  /// Storage keys (GetStorage).
  static const String boxName = 'sushimoo';
  static const String keyToken = 'token';
  static const String keyUser = 'user';
  static const String keyTheme = 'theme';
  static const String keyShift = 'shift';

  /// Payment methods (mirrors metode_pembayaran seed).
  static const List<String> paymentMethods = ['Cash', 'QRIS', 'Debit'];
}

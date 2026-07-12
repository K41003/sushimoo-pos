class AppConstants {
  AppConstants._();

  // ALAMAT IP SUDAH DIPERBAIKI SECARA LENGKAP DAN BENAR
  static const String baseUrl = "http://10.0.2.2/api";

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

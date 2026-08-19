// ============================================================================
// TAMBAHKAN baris berikut ke dalam class AppRoutes yang sudah ada di
// app_routes.dart (jangan buat file baru, cukup tambah 1 field):
// ============================================================================
//
//   static const securityBlocked = '/security-blocked';
//
// Lalu di app_pages.dart, tambahkan GetPage baru (tanpa binding, karena
// halaman ini stateless dan hanya menampilkan pesan):
//
//   import '../../modules/security/security_blocked_page.dart';
//   ...
//   GetPage(
//     name: AppRoutes.securityBlocked,
//     page: () => const SecurityBlockedPage(),
//   ),
// ============================================================================

# Perbaikan: Black Screen di Perangkat Asli & Alur Order Takeaway

## 1. Root cause black screen di perangkat asli

Ditemukan **dua guard "fail-fast"** yang melempar `StateError` di `kReleaseMode`
tanpa memperhitungkan bahwa app ini berjalan penuh offline
(`AppConstants.localMode = true` — tidak pernah memanggil backend Laravel).

- **`lib/app/constants/app_constants.dart`** — `assertSecureBaseUrlInRelease()`
  dipanggil di `main.dart` **sebelum `runApp()`**. Karena default `baseUrl`
  masih `http://10.0.2.2/api` dan biasanya tidak ada
  `--dart-define=API_BASE_URL=https://...` saat build APK biasa untuk
  perangkat asli, di `kReleaseMode` fungsi ini langsung `throw` →
  **`runApp()` tidak pernah terpanggil** → layar hitam permanen. Ini tidak
  pernah muncul saat `flutter run` debug di emulator karena `kReleaseMode`
  bernilai `false` di sana — makanya baru terlihat begitu diinstal sebagai
  APK release di HP.
  **Fix:** fungsi ini sekarang `return` lebih awal jika `localMode == true`,
  karena `baseUrl` memang tidak dipakai sama sekali dalam mode ini.

- **`lib/app/services/ssl_pinning_interceptor.dart`** — constructor
  `SslPinningInterceptor()` punya guard yang sama (`kReleaseMode` + fingerprint
  pinning kosong → `throw`). Karena hampir semua controller (`PosController`,
  `PaymentController`, `AuthService`, `ShiftController`, dst.) memegang field
  `final ApiClient _api = ApiClient.to;` yang dievaluasi **eager**, bug ini
  bisa membuat app crash lagi setiap kali membuka halaman POS/Payment/dll,
  walau `ApiClient` sebenarnya tidak pernah dipakai di local mode.
  **Fix:** guard ini sekarang hanya aktif jika `!AppConstants.localMode`.

- **`lib/main.dart`** — ditambahkan `runZonedGuarded` +
  `FlutterError.onError` + `PlatformDispatcher.instance.onError` sebagai
  jaring pengaman: kalau ada error tak terduga lain di masa depan, minimal
  akan ter-log dan (untuk error widget build) menampilkan error widget,
  bukan diam-diam jadi layar hitam tanpa jejak.
- Ditambahkan `GoogleFonts.config.allowRuntimeFetching = false;` — karena
  app ini didesain 100% offline, teks tidak boleh bergantung pada fetch
  font dari jaringan (fonts.gstatic.com) saat pertama kali dibuka di HP
  tanpa/dengan koneksi lambat.

## 2. Bug yang menghalangi alur order takeaway

**`lib/app/services/local_data_service.dart` → `payTransaction()`**

Kode lama:
```dart
await setTableStatus(txRows.first['id_meja'] as int, 'available');
```

Untuk order **takeaway**, kolom `id_meja` di database memang `NULL` (sesuai
desain — lihat migrasi skema v1→v2 di `database_helper.dart` yang membuat
`id_meja` nullable persis supaya takeaway bisa jalan). Cast `as int` tanpa
null-check ini **selalu throw** `type 'Null' is not a subtype of type 'int'`
tepat saat kasir menekan tombol **Bayar** untuk order takeaway — setelah
baris pembayaran sudah sempat diinsert ke DB, tapi sebelum
`EasyLoading.dismiss()` / navigasi ke halaman struk sempat jalan. Akibatnya:
spinner "Memproses pembayaran..." macet, order takeaway tidak pernah sampai
ke halaman struk.

**Fix:**
```dart
final idMeja = txRows.first['id_meja'] as int?;
if (idMeja != null) {
  await setTableStatus(idMeja, 'available');
}
```

Semua tempat lain yang membaca `id_meja`/`idMeja` (model `Transaction`,
`offline_queue_service.dart`, `printer_service.dart`, `receipt_page.dart`,
dsb.) sudah null-safe — ini satu-satunya cast yang bermasalah.

## 3. Verifikasi alur takeaway end-to-end (manual code review)

Login → buka shift → POS (tap "Takeaway", tanpa perlu pilih meja) → tambah
item ke cart → **Place Order** (`PosController.placeOrder`, `tableId: null`)
→ `LocalDataService.createTransaction` (insert `transaksi` dengan
`id_meja = NULL`, skip update status meja karena `tableId == null`) →
cetak kitchen ticket (aman walau printer tidak terhubung — no-op) → halaman
**Payment** → `PaymentController.pay()` → `LocalDataService.payTransaction`
(sekarang null-safe) → halaman **Receipt** (menampilkan "Takeaway" pada
baris "Table / Layanan" karena `trx.table == null`).

Semua langkah di atas sudah diverifikasi tidak melempar exception untuk
kasus takeaway setelah fix di atas diterapkan.

## File yang diubah

- `lib/main.dart`
- `lib/app/constants/app_constants.dart`
- `lib/app/services/ssl_pinning_interceptor.dart`
- `lib/app/services/local_data_service.dart`

## Catatan build

Karena `localMode = true` adalah keputusan arsitektur (bukan toggle
per-build), build APK release sekarang **tidak perlu** lagi
`--dart-define=API_BASE_URL=...` maupun
`--dart-define=PINNED_FINGERPRINT_LEAF/BACKUP=...` supaya bisa berjalan.
Kedua dart-define itu baru wajib lagi kalau suatu saat `localMode` diubah
menjadi `false` (app disambungkan ke backend Laravel sungguhan) — dan saat
itu terjadi, pastikan juga fingerprint SSL pinning yang asli (bukan
placeholder) di-inject saat build release.

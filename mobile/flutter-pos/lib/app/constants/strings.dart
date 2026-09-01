/// Centralized Indonesian-language UI strings. This is the single
/// source of truth for reusable labels — the whole app now ships in
/// Bahasa Indonesia only (no language switcher, no English fallback).
class AppStrings {
  AppStrings._();

  static const String appName = 'SUSHIMOO POS';
  static const String tagline = 'Kasir Restoran Jepang';

  static const String login = 'Masuk';
  static const String username = 'Username';
  static const String password = 'Kata Sandi';
  static const String dashboard = 'Dashboard';
  static const String pos = 'Kasir';
  static const String cart = 'Keranjang';
  static const String payment = 'Pembayaran';
  static const String shift = 'Shift';
  static const String expense = 'Pengeluaran';
  static const String closing = 'Tutup Kasir';
  static const String report = 'Laporan';
  static const String setting = 'Pengaturan';
  static const String category = 'Kategori';
  static const String product = 'Produk';
  static const String ingredient = 'Bahan Baku';
  static const String stock = 'Stok';
  static const String table = 'Meja';

  static const String totalSales = 'Total Penjualan';
  static const String transactions = 'Transaksi';
  static const String products = 'Produk';
  static const String expenses = 'Pengeluaran';
  static const String currentShift = 'Shift Aktif';
  static const String salesToday = 'Penjualan Hari Ini';
  static const String ordersToday = 'Order Hari Ini';

  static const String subtotal = 'Subtotal';
  static const String tax = 'Pajak';
  static const String grandTotal = 'Total Bayar';
  static const String change = 'Kembalian';
  static const String received = 'Diterima';
  static const String placeOrder = 'Buat Pesanan';
  static const String payNow = 'Bayar Sekarang';

  static const String empty = 'Belum ada data';
  static const String loading = 'Memuat...';
  static const String errorGeneric = 'Terjadi kesalahan';
  static const String success = 'Berhasil';

  // Reusable CRUD action/status labels shared across Category, Product,
  // Ingredient, Stock, Table, Expense and other simple list+form modules.
  static const String saving = 'Menyimpan...';
  static const String deleting = 'Menghapus...';
  static const String saved = 'Tersimpan';
  static const String deleted = 'Terhapus';
  static const String updated = 'Diperbarui';
  static const String confirmDeleteTitle = 'Hapus Data';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String save = 'Simpan';
  static const String edit = 'Ubah';
  static const String add = 'Tambah';
  static const String required = 'wajib diisi';
}

/// Maps internal status/enum values (stored in the database and used for
/// logic comparisons like `status == 'available'`) to their Indonesian
/// display label. The stored value itself is intentionally left in
/// English/lowercase — changing it would require touching every seed
/// row, comparison, and API contract across the app; only what the user
/// *reads* needs to be Indonesian.
String statusLabel(String status) {
  switch (status) {
    case 'available':
      return 'TERSEDIA';
    case 'occupied':
      return 'TERPAKAI';
    case 'reserved':
      return 'DIPESAN';
    case 'cleaning':
      return 'DIBERSIHKAN';
    case 'open':
      return 'BUKA';
    case 'closed':
      return 'TUTUP';
    case 'pending':
      return 'MENUNGGU';
    case 'paid':
      return 'LUNAS';
    case 'success':
      return 'BERHASIL';
    case 'void':
      return 'DIBATALKAN';
    case 'cancelled':
      return 'DIBATALKAN';
    default:
      return status.toUpperCase();
  }
}

class AppRoles {
  AppRoles._();
  static const String admin = 'Admin';
  static const String kasir = 'Kasir';
}

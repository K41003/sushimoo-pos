export interface Role {
  id_role: number;
  nama_role: 'Admin' | 'Kasir';
  deskripsi: string;
}

export interface User {
  id_user: number;
  id_role: number;
  nama: string;
  username: string;
  status: number; // 1 = aktif, 0 = nonaktif
}

export interface Category {
  id_kategori: number;
  nama_kategori: string;
  deskripsi: string;
  status: number; // 1 = aktif, 0 = nonaktif
}

export interface Product {
  id_produk: number;
  id_kategori: number;
  nama_produk: string;
  harga: number;
  gambar?: string | null;
  status: number; // 1 = aktif, 0 = nonaktif
  stok: number; // Combined for easy tracking in-memory
}

export interface Table {
  id_meja: number;
  nomor_meja: string;
  kapasitas: number;
  status: 'available' | 'occupied' | 'reserved' | 'cleaning';
}

export interface Shift {
  id_shift: number;
  id_user: number;
  open_time: string;
  close_time?: string | null;
  petty_cash: number; // Modal awal
  status: 'open' | 'closed';
  actual_cash?: number; // Uang riil laci saat closing
}

export interface PettyCash {
  id_pettycash: number;
  id_shift: number;
  nominal: number;
  keterangan: string;
  created_at: string;
}

export interface TransactionDetail {
  id_detail: number;
  id_transaksi: number;
  id_produk: number;
  nama_produk: string; // denormalized for receipt easy display
  qty: number;
  harga: number;
  subtotal: number;
}

export interface Transaction {
  id_transaksi: number;
  invoice_number: string;
  id_shift: number;
  id_user: number;
  id_meja: number; // 0 for takeaway
  tanggal: string;
  total: number;
  status: 'pending' | 'paid' | 'cancelled'; // cancelled = void
  details: TransactionDetail[];
  id_metode?: number;
  uang_diterima?: number;
  kembalian?: number;
  waktu_bayar?: string;
  void_reason?: string;
}

export interface PaymentMethod {
  id_metode: number;
  nama_metode: string;
  status: number;
}

export interface Expense {
  id_pengeluaran: number;
  id_shift: number;
  kategori: string;
  nominal: number;
  keterangan: string;
  tanggal: string;
}

export interface Closing {
  id_closing: number;
  id_shift: number;
  total_penjualan: number;
  total_cash: number;
  total_qris: number;
  total_debit: number;
  total_pengeluaran: number;
  saldo_akhir: number; // modal awal + cash - pengeluaran
  waktu_closing: string;
  status: 'success' | 'cancelled';
}

export interface ActivityLog {
  id_log: number;
  id_user?: number;
  aktivitas: string;
  ip_address: string;
  created_at: string;
}

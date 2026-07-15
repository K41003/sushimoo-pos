import { Category, Product, Table, PaymentMethod, User } from './types';

export const INITIAL_USERS: User[] = [
  { id_user: 1, id_role: 1, nama: 'Takeshi Yamada (Owner)', username: 'admin', status: 1 },
  { id_user: 2, id_role: 2, nama: 'Siti Rahma (Kasir)', username: 'kasir', status: 1 }
];

export const INITIAL_CATEGORIES: Category[] = [
  { id_kategori: 1, nama_kategori: 'Makanan Utama', deskripsi: 'Menu utama sushi, donburi, dan noodle', status: 1 },
  { id_kategori: 2, nama_kategori: 'Makanan Ringan', deskripsi: 'Appetizer dan camilan Jepang', status: 1 },
  { id_kategori: 3, nama_kategori: 'Minuman', deskripsi: 'Minuman dingin dan hangat', status: 1 },
  { id_kategori: 4, nama_kategori: 'Dessert', deskripsi: 'Penutup dan hidangan manis', status: 1 },
  { id_kategori: 5, nama_kategori: 'Paket Hemat', deskripsi: 'Paket kombo sushi hemat', status: 1 },
];

export const INITIAL_PRODUCTS: Product[] = [
  // Makanan Utama
  { id_produk: 1, id_kategori: 1, nama_produk: 'Sushi Salmon Roll', harga: 45000, status: 1, stok: 50 },
  { id_produk: 2, id_kategori: 1, nama_produk: 'Sushi Tuna Roll', harga: 48000, status: 1, stok: 45 },
  { id_produk: 3, id_kategori: 1, nama_produk: 'Donburi Chicken Katsu', harga: 38000, status: 1, stok: 40 },
  { id_produk: 4, id_kategori: 1, nama_produk: 'Ramen Shoyu', harga: 42000, status: 1, stok: 35 },
  { id_produk: 5, id_kategori: 1, nama_produk: 'Udon Seafood', harga: 40000, status: 1, stok: 30 },
  { id_produk: 6, id_kategori: 1, nama_produk: 'Temaki Ebi', harga: 35000, status: 1, stok: 50 },
  
  // Makanan Ringan
  { id_produk: 7, id_kategori: 2, nama_produk: 'Edamame', harga: 18000, status: 1, stok: 100 },
  { id_produk: 8, id_kategori: 2, nama_produk: 'Gyoza (5 pcs)', harga: 28000, status: 1, stok: 60 },
  { id_produk: 9, id_kategori: 2, nama_produk: 'Takoyaki (4 pcs)', harga: 25000, status: 1, stok: 80 },
  { id_produk: 10, id_kategori: 2, nama_produk: 'Karaage', harga: 30000, status: 1, stok: 50 },
  
  // Minuman
  { id_produk: 11, id_kategori: 3, nama_produk: 'Matcha Latte', harga: 22000, status: 1, stok: 75 },
  { id_produk: 12, id_kategori: 3, nama_produk: 'Ocha (Teh Hijau)', harga: 12000, status: 1, stok: 200 },
  { id_produk: 13, id_kategori: 3, nama_produk: 'Coca Cola', harga: 10000, status: 1, stok: 120 },
  { id_produk: 14, id_kategori: 3, nama_produk: 'Juice Jeruk', harga: 18000, status: 1, stok: 40 },
  { id_produk: 15, id_kategori: 3, nama_produk: 'Americano Ice', harga: 20000, status: 1, stok: 60 },
  
  // Dessert
  { id_produk: 16, id_kategori: 4, nama_produk: 'Mochi Ice Cream', harga: 20000, status: 1, stok: 80 },
  { id_produk: 17, id_kategori: 4, nama_produk: 'Cheesecake', harga: 26000, status: 1, stok: 30 },
  { id_produk: 18, id_kategori: 4, nama_produk: 'Dorayaki', harga: 15000, status: 1, stok: 50 },
  
  // Paket Hemat
  { id_produk: 19, id_kategori: 5, nama_produk: 'Paket Sushi Family', harga: 150000, status: 1, stok: 20 },
  { id_produk: 20, id_kategori: 5, nama_produk: 'Paket Ramen + Drink', harga: 55000, status: 1, stok: 40 },
  { id_produk: 21, id_kategori: 5, nama_produk: 'Paket Bento Kombo', harga: 65000, status: 1, stok: 35 }
];

export const INITIAL_TABLES: Table[] = [
  { id_meja: 1, nomor_meja: 'M01', kapasitas: 4, status: 'available' },
  { id_meja: 2, nomor_meja: 'M02', kapasitas: 4, status: 'available' },
  { id_meja: 3, nomor_meja: 'M03', kapasitas: 6, status: 'available' },
  { id_meja: 4, nomor_meja: 'M04', kapasitas: 2, status: 'available' },
  { id_meja: 5, nomor_meja: 'M05', kapasitas: 2, status: 'available' }
];

export const INITIAL_PAYMENT_METHODS: PaymentMethod[] = [
  { id_metode: 1, nama_metode: 'Cash', status: 1 },
  { id_metode: 2, nama_metode: 'QRIS', status: 1 },
  { id_metode: 3, nama_metode: 'Debit', status: 1 }
];

export function getStorage<T>(key: string, defaultValue: T): T {
  try {
    const value = localStorage.getItem(`sushimoo_${key}`);
    if (value) {
      return JSON.parse(value) as T;
    }
  } catch (e) {
    console.error(`Error reading ${key} from localStorage:`, e);
  }
  return defaultValue;
}

export function setStorage<T>(key: string, value: T): void {
  try {
    localStorage.setItem(`sushimoo_${key}`, JSON.stringify(value));
  } catch (e) {
    console.error(`Error writing ${key} to localStorage:`, e);
  }
}

export function initializeDatabase() {
  if (!localStorage.getItem('sushimoo_initialized')) {
    setStorage('users', INITIAL_USERS);
    setStorage('categories', INITIAL_CATEGORIES);
    setStorage('products', INITIAL_PRODUCTS);
    setStorage('tables', INITIAL_TABLES);
    setStorage('payment_methods', INITIAL_PAYMENT_METHODS);
    setStorage('shifts', []);
    setStorage('transactions', []);
    setStorage('expenses', []);
    setStorage('closings', []);
    setStorage('logs', [
      {
        id_log: 1,
        id_user: 1,
        aktivitas: 'Database diinisialisasi dengan data default Sushimoo',
        ip_address: '127.0.0.1',
        created_at: new Date().toISOString()
      }
    ]);
    localStorage.setItem('sushimoo_initialized', 'true');
  }
}

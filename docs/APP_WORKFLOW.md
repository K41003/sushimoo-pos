# SUSHIMOO POS - Application Workflow

Dokumen ini menjelaskan workflow operasional aplikasi berdasarkan implementasi Laravel API dan Flutter POS saat ini.

## 1. Aktor dan Hak Akses

| Aktor | Fokus kerja | Akses utama |
|---|---|---|
| Admin | Master data, monitoring, void transaksi, laporan | Dashboard admin, kategori, produk, bahan baku, stok, meja, riwayat shift, transaksi, closing, laporan |
| Kasir | Operasional outlet harian | Login, buka shift, POS, pembayaran, pengeluaran, closing shift, laporan harian |

Semua endpoint selain `POST /login` memakai `auth:sanctum`. Role dijaga oleh middleware `role:`.

## 2. Workflow Harian Kasir

```mermaid
flowchart TD
    A["Kasir login"] --> B["Ambil token Sanctum"]
    B --> C["Cek shift aktif"]
    C -->|Belum ada| D["Buka shift dengan petty cash"]
    C -->|Ada| E["Masuk POS"]
    D --> E
    E --> F["Load kategori, produk, dan meja"]
    F --> G["Pilih produk dan meja"]
    G --> H["Buat transaksi pending"]
    H --> I["Cetak kitchen ticket"]
    I --> J["Pilih metode pembayaran"]
    J --> K["Bayar transaksi"]
    K --> L["Transaksi menjadi paid"]
    L --> M["Catat pengeluaran jika ada"]
    M --> N["Closing shift"]
```

### Detail aturan

- Kasir harus punya shift `open` sebelum membuat transaksi.
- Saat transaksi dibuat, meja berubah menjadi `occupied`.
- Client hanya mengirim `id_produk`, `qty`, dan `catatan`; harga selalu dihitung ulang dari database.
- Transaksi baru berstatus `pending`.
- Transaksi `paid` tidak boleh diubah.
- Pembayaran cash ditolak jika `uang_diterima` kurang dari total transaksi.
- Setiap transaksi hanya boleh memiliki satu pembayaran.

## 3. Workflow Transaksi

```mermaid
sequenceDiagram
    participant F as Flutter POS
    participant API as Laravel API
    participant DB as Database

    F->>API: POST /api/transaksi {id_meja, items}
    API->>DB: Cari shift open milik kasir
    API->>DB: Ambil harga produk dari tabel produk
    API->>DB: DB transaction: create transaksi + detail + update meja
    DB-->>API: Transaksi pending
    API-->>F: Transaction + details
    F->>F: Cetak kitchen ticket
```

Payload transaksi:

```json
{
  "id_meja": 1,
  "items": [
    {
      "id_produk": 10,
      "qty": 2,
      "catatan": "Tanpa wasabi"
    }
  ]
}
```

Field `harga` tidak dipakai dari client untuk mencegah manipulasi total.

## 4. Workflow Pembayaran

```mermaid
sequenceDiagram
    participant F as Flutter POS
    participant API as Laravel API
    participant DB as Database

    F->>API: POST /api/transaksi/{id}/pembayaran
    API->>DB: DB transaction + lock transaksi
    API->>DB: Validasi status belum paid
    API->>DB: Validasi cash cukup jika metode Cash
    API->>DB: Create pembayaran
    API->>DB: Update transaksi menjadi paid
    DB-->>API: Payment success
    API-->>F: Payment + transaction
```

| Kondisi | Hasil |
|---|---|
| Transaksi sudah `paid` | Ditolak |
| Cash kurang dari total | Ditolak |
| Payment kedua untuk transaksi sama | Ditolak oleh unique index `pembayaran.id_transaksi` |
| Non-cash tanpa `uang_diterima` | Dianggap sebesar total transaksi |

## 5. Workflow Admin

```mermaid
flowchart TD
    A["Admin login"] --> B["Dashboard admin"]
    B --> C["Kelola master data"]
    C --> C1["Kategori"]
    C --> C2["Produk dan resep"]
    C --> C3["Bahan baku dan stok"]
    C --> C4["Meja"]
    B --> D["Pantau transaksi"]
    D --> E["Void transaksi jika perlu"]
    B --> F["Lihat laporan dan closing history"]
```

### Detail aturan

- Admin bisa melihat daftar semua transaksi.
- Admin bisa void transaksi.
- Void transaksi mengubah status menjadi `cancelled` dan mengembalikan meja menjadi `available`.
- Admin mengakses laporan bulanan, statistik, riwayat shift, dan riwayat closing.

## 6. Status Data Utama

### Transaksi

| Status | Arti | Transisi |
|---|---|---|
| `pending` | Order dibuat, belum dibayar | Bisa menjadi `paid` atau `cancelled` |
| `paid` | Order sudah dibayar | Tidak boleh di-update |
| `cancelled` | Order dibatalkan oleh Admin | Final |

### Meja

| Status | Arti | Diubah saat |
|---|---|---|
| `available` | Meja kosong | Awal / void |
| `occupied` | Ada transaksi pending/aktif | Transaksi dibuat |

### Shift

| Status | Arti |
|---|---|
| `open` | Kasir sedang bertugas |
| `closed` | Shift sudah selesai dan siap closing/report |

## 7. Checklist QA Manual

1. Login sebagai Kasir.
2. Buka shift.
3. Buat transaksi dengan item valid tanpa mengirim `harga`.
4. Pastikan total mengikuti harga produk di database.
5. Coba bayar cash dengan nominal kurang dari total, harus gagal.
6. Bayar cash dengan nominal cukup, harus sukses dan ada kembalian.
7. Coba bayar transaksi yang sama lagi, harus gagal.
8. Coba update transaksi yang sudah `paid`, harus gagal.
9. Login sebagai Admin.
10. Void transaksi pending dan pastikan meja kembali `available`.
11. Cek laporan harian/bulanan.

## 8. Catatan Implementasi

- Backend memakai pola `Controller -> Service -> Repository -> Model`.
- Logika bisnis transaksi dan pembayaran berada di service.
- Operasi kritis transaksi dan pembayaran memakai database transaction.
- Payment memakai row lock saat mengubah status transaksi untuk mengurangi risiko double payment.
- Migration `2026_07_12_000001_add_unique_transaction_to_pembayaran_table.php` memastikan satu transaksi hanya punya satu pembayaran.

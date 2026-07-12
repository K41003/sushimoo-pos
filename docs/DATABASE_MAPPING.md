# Database Mapping — schema.sql → Laravel Models

All tables use custom BIGINT PKs. Each model sets `$table`, `$primaryKey`, `$fillable`, `$casts`, `$timestamps = true`. Enums are stored as strings.

| Table | Model | PK | fillable | casts | relationships |
|---|---|---|---|---|---|
| roles | Role | id_role | nama_role, deskripsi | – | hasMany: users |
| users | User | id_user | id_role, nama, username, password, status | status:bool | belongsTo: role; hasMany: shifts, transactions, activityLogs |
| kategori_produk | Category | id_kategori | nama_kategori, deskripsi, status | status:bool | hasMany: products |
| produk | Product | id_produk | id_kategori, nama_produk, harga, gambar, status | harga:decimal:2, status:bool | belongsTo: category; hasMany: details, recipes |
| bahan_baku | Ingredient | id_bahan | nama_bahan, satuan, minimal_stok | minimal_stok:decimal:2 | hasMany: stocks, recipes |
| stok_bahan | Stock | id_stok | id_bahan, jumlah | jumlah:decimal:2 | belongsTo: ingredient |
| resep_produk | Recipe | id_resep | id_produk, id_bahan, qty | qty:decimal:2 | belongsTo: product, ingredient |
| meja | Table | id_meja | nomor_meja, kapasitas, status | – | hasMany: transactions |
| shifts | Shift | id_shift | id_user, open_time, close_time, petty_cash, status | petty_cash:decimal:2 | belongsTo: user; hasMany: pettyCashes, transactions, expenses; hasOne: closing |
| petty_cash | PettyCash | id_pettycash | id_shift, nominal, keterangan | nominal:decimal:2 | belongsTo: shift |
| transaksi | Transaction | id_transaksi | invoice_number, id_shift, id_user, id_meja, tanggal, total, status | total:decimal:2, tanggal:datetime, status:string | belongsTo: shift, user, table; hasMany: details; hasOne: payment |
| detail_transaksi | TransactionDetail | id_detail | id_transaksi, id_produk, qty, harga, subtotal | qty:int, harga:decimal:2, subtotal:decimal:2 | belongsTo: transaction, product |
| metode_pembayaran | PaymentMethod | id_metode | nama_metode, status | status:bool | hasMany: payments |
| pembayaran | Payment | id_pembayaran | id_transaksi, id_metode, total_bayar, uang_diterima, kembalian, waktu_bayar, status | total_bayar:decimal:2, uang_diterima:decimal:2, kembalian:decimal:2, waktu_bayar:datetime | belongsTo: transaction, method |
| pengeluaran | Expense | id_pengeluaran | id_shift, kategori, nominal, keterangan, tanggal | nominal:decimal:2, tanggal:datetime | belongsTo: shift |
| closing_kasir | Closing | id_closing | id_shift, total_penjualan, total_cash, total_qris, total_pengeluaran, saldo_akhir, waktu_closing, status | decimal:2 fields, waktu_closing:datetime | belongsTo: shift |
| activity_logs | ActivityLog | id_log | id_user, aktivitas, ip_address, created_at | created_at:datetime | belongsTo: user |

## Seed Data (seed.sql / Seeders)
- roles: Admin, Kasir
- metode_pembayaran: Cash, QRIS, Debit
- meja: M01..M05
- users: admin / admin123 (role Admin)

## Status Enums
- meja.status: available | occupied | reserved | cleaning
- shifts.status: open | closed
- transaksi.status: pending | paid | cancelled
- pembayaran.status: success | failed
- closing_kasir.status: success | cancelled

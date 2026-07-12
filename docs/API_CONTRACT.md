# API Contract — SUSHIMOO POS

Base URL: `/api` · Auth: `Authorization: Bearer <sanctum_token>` · Format: `application/json`

## Standard Envelope
```json
// Success
{ "success": true, "message": "Success", "data": {} }
// Error
{ "success": false, "message": "Error message" }
// Validation / listing
{ "success": true, "message": "Success", "data": { "items": [], "meta": { "page":1,"perPage":15,"total":0 } } }
```

## Auth
| Method | Path | Auth | Request | Response data |
|---|---|---|---|---|
| POST | `/login` | ❌ | `{username, password}` | `{token, user}` |
| POST | `/logout` | ✅ | `{}` | `{}` |
| GET  | `/me` | ✅ | – | `user` |

## Category (`/categories`) — role: Admin
| Method | Path | Request | Response |
|---|---|---|---|
| GET | `/categories` | query: `q?, page?, perPage?` | list + meta |
| GET | `/categories/{id}` | – | item |
| POST | `/categories` | `{nama_kategori, deskripsi?, status?}` | item |
| PUT | `/categories/{id}` | same as POST | item |
| DELETE | `/categories/{id}` | – | `{}` |

## Product (`/products`) — role: Admin
| Method | Path | Request | Response |
|---|---|---|---|
| GET | `/products` | `q?, id_kategori?, page?, perPage?` | list + meta |
| GET | `/products/{id}` | – | item (+category) |
| POST | `/products` | `{id_kategori, nama_produk, harga, gambar?, status?, recipes?:[{id_bahan,qty}]}` | item |
| PUT | `/products/{id}` | same | item |
| DELETE | `/products/{id}` | – | `{}` |

## Ingredient (`/bahan-baku`) — role: Admin
| Method | Path | Request | Response |
|---|---|---|---|
| GET | `/bahan-baku` | `q?, page?, perPage?` | list |
| POST | `/bahan-baku` | `{nama_bahan, satuan, minimal_stok?}` | item |
| PUT | `/bahan-baku/{id}` | same | item |
| DELETE | `/bahan-baku/{id}` | – | `{}` |

## Stock (`/stok-bahan`) — role: Admin
| Method | Path | Request | Response |
|---|---|---|---|
| GET | `/stok-bahan` | `q?, page?, perPage?` | list (+ingredient) |
| POST | `/stok-bahan` | `{id_bahan, jumlah}` (adjustment) | item |
| PUT | `/stok-bahan/{id}` | `{jumlah}` | item |
| DELETE | `/stok-bahan/{id}` | – | `{}` |

## Table (`/meja`) — role: Admin
| Method | Path | Request | Response |
|---|---|---|---|
| GET | `/meja` | `status?, page?, perPage?` | list |
| POST | `/meja` | `{nomor_meja, kapasitas?, status?}` | item |
| PUT | `/meja/{id}` | same | item |
| DELETE | `/meja/{id}` | – | `{}` |

## Shift (`/shifts`) — open/close: Kasir
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| GET | `/shifts/active` | ✅ | – | current open shift or null |
| POST | `/shifts/open` | ✅ | `{petty_cash}` | item |
| POST | `/shifts/{id}/petty-cash` | ✅ | `{nominal, keterangan?}` | item |
| POST | `/shifts/{id}/close` | ✅ | – | closing record |
| GET | `/shifts/history` | ✅(Admin) | `page?, perPage?` | list |

## Transaction (`/transaksi`) — Kasir create, Admin monitor
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/transaksi` | ✅ | `{id_meja, items:[{id_produk,qty,harga,catatan?}], tanggal?}` | item (+details) |
| GET | `/transaksi` | ✅ | `status?, id_meja?, page?, perPage?` | list |
| GET | `/transaksi/{id}` | ✅ | – | item (+details) |
| PUT | `/transaksi/{id}` | ✅ | `{items:[...]}` | updated item |
| POST | `/transaksi/{id}/void` | ✅(Admin) | `{alasan}` | voided item |

## Payment (`/pembayaran`)
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/transaksi/{id}/pembayaran` | ✅ | `{id_metode, uang_diterima?}` | payment (+transaction) |

## Expense (`/pengeluaran`) — Kasir
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| GET | `/pengeluaran` | ✅ | `page?, perPage?` | list |
| POST | `/pengeluaran` | ✅ | `{kategori, nominal, keterangan?, tanggal?}` | item |
| PUT | `/pengeluaran/{id}` | ✅ | same | item |
| DELETE | `/pengeluaran/{id}` | ✅ | – | `{}` |

## Closing (`/closing`) — Kasir
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| POST | `/shifts/{id}/closing` | ✅ | – | closing record |
| GET | `/closing/history` | ✅(Admin) | `page?, perPage?` | list |

## Reports (`/reports`)
| Method | Path | Auth | Request | Response |
|---|---|---|---|---|
| GET | `/reports/daily` | ✅ | `date?` | `{sales, orders, cash, qris, expenses, transactions[]}` |
| GET | `/reports/monthly` | ✅(Admin) | `month?, year?` | `{total, byDay[], byMethod[]}` |
| GET | `/reports/statistics` | ✅(Admin) | `from?, to?` | `{salesTrend[], topProducts[], leastProducts[], cashflow[]}` |
| GET | `/reports/last-7-days` | ✅ | – | `{days[], totals[]}` |

## Dashboard (`/dashboard`)
| Method | Path | Auth | Response |
|---|---|---|---|
| GET | `/dashboard/admin` | ✅(Admin) | `{totalSales, transactions, products, expenses, salesTrend, topProducts}` |
| GET | `/dashboard/cashier` | ✅ | `{currentShift, salesToday, ordersToday}` |

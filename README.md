# SUSHIMOO POS

Aplikasi **Point of Sale (POS)** untuk restoran Jepang yang terdiri dari:

- **Backend** — REST API berbasis Laravel 12 + Sanctum (`backend/laravel-api`)
- **Mobile** — Aplikasi Flutter (GetX) (`mobile/flutter-pos`)

Arsitektur: `Flutter App → REST API → Laravel Backend → MySQL`

---

## Prasyarat

Sebelum menjalankan project, pastikan tool berikut sudah terpasang:

| Tool | Versi Minimum | Keperluan |
| --- | --- | --- |
| PHP | `^8.2` | Menjalankan Laravel |
| Composer | Terbaru | Dependency PHP |
| Node.js & npm | `^18` | Vite / asset build Laravel |
| MySQL / MariaDB | `^5.7` / `^10` | Database backend |
| Flutter SDK | `^3.4.0` | Menjalankan aplikasi mobile |
| Android Studio / VS Code | — | Emulator / device & IDE |

---

## 1. Menjalankan Backend (Laravel API)

Buka terminal di folder backend:

```bash
cd backend/laravel-api
```

### a. Install dependency

```bash
composer install
npm install
```

### b. Konfigurasi environment

Salin file `.env.example` menjadi `.env`, lalu sesuaikan koneksi database:

```bash
cp .env.example .env
```

Edit `.env` bagian database (sesuaikan dengan MySQL lokal kamu):

```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sushimoo_pos
DB_USERNAME=root
DB_PASSWORD=
```

> Buat database `sushimoo_pos` terlebih dahulu di MySQL:
> ```sql
> CREATE DATABASE sushimoo_pos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> ```

### c. Generate app key & migrasi + seed

```bash
php artisan key:generate
php artisan migrate --seed
```

### d. Jalankan server

```bash
php artisan serve
```

Backend akan berjalan di `http://localhost:8000` dan API tersedia di `http://localhost:8000/api`.

> Jika ingin membuild asset (Vite) saat development:
> ```bash
> npm run dev
> ```

---

## 2. Menjalankan Mobile App (Flutter)

Buka terminal di folder mobile:

```bash
cd mobile/flutter-pos
```

### a. Install dependency

```bash
flutter pub get
```

### b. Sesuaikan Base URL API

Alamat API diatur di `lib/app/constants/app_constants.dart`:

```dart
static const String baseUrl = "http://10.0.2.2/api";
```

- **Emulator Android**: `http://10.0.2.2/api` (alamat loopback ke `localhost` komputer).
- **Device fisik / iOS Simulator**: ganti dengan IP lokal komputer kamu, misal
  `http://192.168.1.10:8000/api` (pastikan firewall mengizinkan port 8000).

### c. Jalankan aplikasi

Pastikan emulator/device sudah terhubung, lalu:

```bash
flutter run
```

Untuk build APK release:

```bash
flutter build apk --release
```

---

## 3. Struktur Project

```text
sushimoo-pos/
├── backend/
│   └── laravel-api/        # REST API (Laravel 12 + Sanctum)
├── mobile/
│   └── flutter-pos/        # Aplikasi mobile (Flutter + GetX)
├── database/               # Schema & seed SQL
├── docs/                   # Dokumentasi tambahan (ERD, API contract, dll)
├── assets/                 # Aset desain
└── Project-Structure.md    # Penjelasan struktur & modul
```

---

## 4. Catatan Tambahan

- **Build runner (opsional)**: Jika mengubah model dengan `json_serializable`, jalankan
  `flutter pub run build_runner build --delete-conflicting-outputs` di folder `mobile/flutter-pos`.
- **Printer**: Aplikasi menggunakan `blue_thermal_printer` untuk cetak struk via Bluetooth thermal printer.
- **Dokumentasi lengkap**: Lihat `Project-Structure.md`, `docs/`, dan `API_CONTRACT.md` untuk detail endpoint, role (Admin/Kasir), dan alur kerja.

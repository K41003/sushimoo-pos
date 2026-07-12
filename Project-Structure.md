# Sushimoo POS Mobile App

## Project Overview

Sushimoo POS adalah aplikasi Point of Sale (POS) Restoran Jepang berbasis Flutter Mobile dan Laravel API yang dirancang untuk mendukung operasional restoran mulai dari transaksi penjualan, manajemen stok bahan baku, petty cash, pengeluaran operasional, hingga closing kasir.

---

# Tech Stack

## Frontend Mobile

- Flutter 3.x
- GetX
- Dio
- Flutter ScreenUtil
- Get Storage
- Blue Thermal Printer
- PDF & Printing

## Backend API

- Laravel 12
- Laravel Sanctum
- REST API

## Database

- MySQL / MariaDB

---

# Architecture

```text
Flutter App
    |
REST API
    |
Laravel Backend
    |
MySQL Database
```

---

# Project Structure

```text
sushimoo-pos/
│
├── backend/
│   └── laravel-api/
│
├── mobile/
│   └── flutter-pos/
│
├── database/
│   ├── schema.sql
│   ├── seed.sql
│   └── erd.drawio
│
├── docs/
│
└── assets/
```

---

# Backend Structure

```text
laravel-api
│
├── app
│   │
│   ├── Http
│   │   ├── Controllers
│   │   │
│   │   ├── Auth
│   │   ├── Dashboard
│   │   ├── Category
│   │   ├── Product
│   │   ├── Table
│   │   ├── Shift
│   │   ├── Transaction
│   │   ├── Payment
│   │   ├── Expense
│   │   ├── Closing
│   │   └── Report
│   │
│   │   ├── Middleware
│   │   └── Requests
│   │
│   ├── Models
│   ├── Services
│   ├── Repositories
│   └── Helpers
│
├── database
│   ├── migrations
│   ├── seeders
│   └── factories
│
├── routes
│   ├── api.php
│   └── web.php
│
└── storage
```

---

# Laravel Models

```text
Role
User

Category
Product

Ingredient
Stock
Recipe

Table

Shift
PettyCash

Transaction
TransactionDetail

Payment
PaymentMethod

Expense

Closing

ActivityLog
```

---

# Flutter Structure

```text
lib
│
├── app
│   ├── routes
│   ├── bindings
│   ├── constants
│   ├── themes
│   └── services
│
├── data
│   ├── models
│   ├── providers
│   ├── repositories
│   └── response
│
├── modules
│
│   ├── splash
│   ├── login
│   ├── dashboard
│   ├── category
│   ├── product
│   ├── table
│   ├── shift
│   ├── pos
│   ├── payment
│   ├── expense
│   ├── report
│   ├── closing
│   └── setting
│
├── shared
│   ├── widgets
│   ├── dialogs
│   ├── extensions
│   └── utils
│
└── main.dart
```

---

# GetX Module Structure

Example Product Module

```text
product
│
├── bindings
│   └── product_binding.dart
│
├── controllers
│   └── product_controller.dart
│
├── views
│   ├── product_page.dart
│   ├── product_form_page.dart
│   └── product_detail_page.dart
│
└── widgets
```

---

# Flutter Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8

  get: ^4.7.2

  dio: ^5.8.0

  get_storage: ^2.1.1

  flutter_screenutil: ^5.9.3

  intl: ^0.20.2

  flutter_easyloading: ^3.0.5

  flutter_svg: ^2.1.0

  blue_thermal_printer: ^1.2.3

  pdf: ^3.11.3

  printing: ^5.14.2

  fl_chart: ^1.0.0

  shimmer: ^3.0.0

  qr_flutter: ^4.1.0

  connectivity_plus: ^6.1.4

  device_info_plus: ^11.5.0
```

---

# Dev Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0

  build_runner: ^2.5.4

  json_serializable: ^6.9.5

  json_annotation: ^4.9.0
```

---

# Assets Structure

```text
assets
│
├── images
│   ├── logo.png
│   ├── splash.png
│   └── empty.png
│
├── icons
│
├── fonts
│
└── animations
```

---

# User Roles

## Admin

### Permissions

- Login
- Dashboard
- Kelola Produk
- Kelola Kategori
- Kelola Stok
- Kelola Meja
- Melihat Transaksi
- Void Transaksi
- Laporan Bulanan
- Statistik Penjualan
- Riwayat Closing Kasir

---

## Kasir

### Permissions

- Login
- Open Shift
- Input Petty Cash
- Membuat Pesanan
- Update Pesanan
- Pembayaran
- Input Pengeluaran
- Rekapitulasi Harian
- Closing Kasir
- Laporan 7 Hari

---

# Sprint Roadmap

## Sprint 1

### Authentication & Master Data

- Login
- Dashboard
- Role Management
- User Management
- Category Management
- Product Management
- Table Management
- Shift Open / Close

---

## Sprint 2

### POS Transaction

- Create Order
- Cart
- Payment
- Printer Integration
- Expense
- Daily Report
- Closing

---

## Sprint 3

### Analytics

- Monthly Report
- Sales Statistics
- Top Selling Product
- Least Selling Product
- Cash Flow Summary

---

# Testing Plan

## Unit Testing

- Authentication
- Product
- Category
- Shift
- Transaction
- Payment

## Integration Testing

```text
Login
 → Open Shift
 → Create Order
 → Payment
 → Expense
 → Closing
```

## User Acceptance Testing

### Admin

- Kelola Produk
- Kelola Kategori
- Kelola Stok
- Laporan

### Kasir

- Shift
- POS
- Pembayaran
- Closing

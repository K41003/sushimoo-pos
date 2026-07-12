-- ==========================================
-- POS RESTORAN JEPANG
-- schema.sql
-- ==========================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS closing_kasir;
DROP TABLE IF EXISTS pengeluaran;
DROP TABLE IF EXISTS pembayaran;
DROP TABLE IF EXISTS metode_pembayaran;
DROP TABLE IF EXISTS detail_transaksi;
DROP TABLE IF EXISTS transaksi;
DROP TABLE IF EXISTS petty_cash;
DROP TABLE IF EXISTS shifts;
DROP TABLE IF EXISTS meja;
DROP TABLE IF EXISTS resep_produk;
DROP TABLE IF EXISTS stok_bahan;
DROP TABLE IF EXISTS bahan_baku;
DROP TABLE IF EXISTS produk;
DROP TABLE IF EXISTS kategori_produk;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- ROLES
-- ==========================================

CREATE TABLE roles (
    id_role BIGINT AUTO_INCREMENT PRIMARY KEY,
    nama_role VARCHAR(50) NOT NULL,
    deskripsi TEXT,
    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- USERS
-- ==========================================

CREATE TABLE users (
    id_user BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_role BIGINT NOT NULL,

    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    status TINYINT(1) DEFAULT 1,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_users_role
        FOREIGN KEY (id_role)
        REFERENCES roles(id_role)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- KATEGORI PRODUK
-- ==========================================

CREATE TABLE kategori_produk (
    id_kategori BIGINT AUTO_INCREMENT PRIMARY KEY,

    nama_kategori VARCHAR(100) NOT NULL,
    deskripsi TEXT,

    status TINYINT(1) DEFAULT 1,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- PRODUK
-- ==========================================

CREATE TABLE produk (
    id_produk BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_kategori BIGINT NOT NULL,

    nama_produk VARCHAR(100) NOT NULL,
    harga DECIMAL(15,2) NOT NULL,

    gambar VARCHAR(255),

    status TINYINT(1) DEFAULT 1,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_produk_kategori
        FOREIGN KEY (id_kategori)
        REFERENCES kategori_produk(id_kategori)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- BAHAN BAKU
-- ==========================================

CREATE TABLE bahan_baku (
    id_bahan BIGINT AUTO_INCREMENT PRIMARY KEY,

    nama_bahan VARCHAR(100) NOT NULL,

    satuan VARCHAR(30) NOT NULL,

    minimal_stok DECIMAL(15,2) DEFAULT 0,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- STOK BAHAN
-- ==========================================

CREATE TABLE stok_bahan (
    id_stok BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_bahan BIGINT NOT NULL,

    jumlah DECIMAL(15,2) DEFAULT 0,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_stok_bahan
        FOREIGN KEY (id_bahan)
        REFERENCES bahan_baku(id_bahan)
        ON UPDATE CASCADE
        ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- RESEP PRODUK
-- ==========================================

CREATE TABLE resep_produk (
    id_resep BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_produk BIGINT NOT NULL,
    id_bahan BIGINT NOT NULL,

    qty DECIMAL(15,2) NOT NULL,

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_resep_produk
        FOREIGN KEY (id_produk)
        REFERENCES produk(id_produk)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_resep_bahan
        FOREIGN KEY (id_bahan)
        REFERENCES bahan_baku(id_bahan)
        ON UPDATE CASCADE
        ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- MEJA
-- ==========================================

CREATE TABLE meja (
    id_meja BIGINT AUTO_INCREMENT PRIMARY KEY,

    nomor_meja VARCHAR(20) NOT NULL,
    kapasitas INT DEFAULT 1,

    status ENUM(
        'available',
        'occupied',
        'reserved',
        'cleaning'
    ) DEFAULT 'available',

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- SHIFT
-- ==========================================

CREATE TABLE shifts (
    id_shift BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_user BIGINT NOT NULL,

    open_time DATETIME,
    close_time DATETIME,

    petty_cash DECIMAL(15,2) DEFAULT 0,

    status ENUM(
        'open',
        'closed'
    ) DEFAULT 'open',

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_shift_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON UPDATE CASCADE
        ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- PETTY CASH
-- ==========================================

CREATE TABLE petty_cash (
    id_pettycash BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_shift BIGINT NOT NULL,

    nominal DECIMAL(15,2) NOT NULL,
    keterangan TEXT,

    created_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_pettycash_shift
        FOREIGN KEY (id_shift)
        REFERENCES shifts(id_shift)
        ON UPDATE CASCADE
        ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- TRANSAKSI
-- ==========================================

CREATE TABLE transaksi (
    id_transaksi BIGINT AUTO_INCREMENT PRIMARY KEY,

    invoice_number VARCHAR(50) NOT NULL UNIQUE,

    id_shift BIGINT NOT NULL,
    id_user BIGINT NOT NULL,
    id_meja BIGINT NOT NULL,

    tanggal DATETIME NOT NULL,

    total DECIMAL(15,2) DEFAULT 0,

    status ENUM(
        'pending',
        'paid',
        'cancelled'
    ) DEFAULT 'pending',

    created_at TIMESTAMP NULL DEFAULT NULL,
    updated_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_transaksi_shift
        FOREIGN KEY (id_shift)
        REFERENCES shifts(id_shift),

    CONSTRAINT fk_transaksi_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user),

    CONSTRAINT fk_transaksi_meja
        FOREIGN KEY (id_meja)
        REFERENCES meja(id_meja)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- DETAIL TRANSAKSI
-- ==========================================

CREATE TABLE detail_transaksi (
    id_detail BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_transaksi BIGINT NOT NULL,
    id_produk BIGINT NOT NULL,

    qty INT NOT NULL,
    harga DECIMAL(15,2) NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,

    CONSTRAINT fk_detail_transaksi
        FOREIGN KEY (id_transaksi)
        REFERENCES transaksi(id_transaksi)
        ON DELETE CASCADE,

    CONSTRAINT fk_detail_produk
        FOREIGN KEY (id_produk)
        REFERENCES produk(id_produk)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- METODE PEMBAYARAN
-- ==========================================

CREATE TABLE metode_pembayaran (
    id_metode BIGINT AUTO_INCREMENT PRIMARY KEY,

    nama_metode VARCHAR(50) NOT NULL,

    status TINYINT(1) DEFAULT 1

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- PEMBAYARAN
-- ==========================================

CREATE TABLE pembayaran (
    id_pembayaran BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_transaksi BIGINT NOT NULL,
    id_metode BIGINT NOT NULL,

    total_bayar DECIMAL(15,2) NOT NULL,

    uang_diterima DECIMAL(15,2) DEFAULT 0,

    kembalian DECIMAL(15,2) DEFAULT 0,

    waktu_bayar DATETIME,

    status ENUM(
        'success',
        'failed'
    ) DEFAULT 'success',

    CONSTRAINT fk_pembayaran_transaksi
        FOREIGN KEY (id_transaksi)
        REFERENCES transaksi(id_transaksi),

    CONSTRAINT fk_pembayaran_metode
        FOREIGN KEY (id_metode)
        REFERENCES metode_pembayaran(id_metode)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- PENGELUARAN
-- ==========================================

CREATE TABLE pengeluaran (
    id_pengeluaran BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_shift BIGINT NOT NULL,

    kategori VARCHAR(100) NOT NULL,

    nominal DECIMAL(15,2) NOT NULL,

    keterangan TEXT,

    tanggal DATETIME NOT NULL,

    CONSTRAINT fk_pengeluaran_shift
        FOREIGN KEY (id_shift)
        REFERENCES shifts(id_shift)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- CLOSING KASIR
-- ==========================================

CREATE TABLE closing_kasir (
    id_closing BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_shift BIGINT NOT NULL,

    total_penjualan DECIMAL(15,2) DEFAULT 0,
    total_cash DECIMAL(15,2) DEFAULT 0,
    total_qris DECIMAL(15,2) DEFAULT 0,
    total_pengeluaran DECIMAL(15,2) DEFAULT 0,
    saldo_akhir DECIMAL(15,2) DEFAULT 0,

    waktu_closing DATETIME,

    status ENUM(
        'success',
        'cancelled'
    ) DEFAULT 'success',

    CONSTRAINT fk_closing_shift
        FOREIGN KEY (id_shift)
        REFERENCES shifts(id_shift)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- ACTIVITY LOG
-- ==========================================

CREATE TABLE activity_logs (
    id_log BIGINT AUTO_INCREMENT PRIMARY KEY,

    id_user BIGINT,

    aktivitas TEXT NOT NULL,

    ip_address VARCHAR(50),

    created_at DATETIME,

    CONSTRAINT fk_log_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- SEED DATA
-- ==========================================

INSERT INTO roles (nama_role, deskripsi)
VALUES
('Admin','Administrator'),
('Kasir','Kasir');

INSERT INTO metode_pembayaran (nama_metode)
VALUES
('Cash'),
('QRIS'),
('Debit');

INSERT INTO meja (nomor_meja, kapasitas)
VALUES
('M01',4),
('M02',4),
('M03',6),
('M04',2),
('M05',2);
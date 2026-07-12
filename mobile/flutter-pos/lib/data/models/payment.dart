import 'num_util.dart';
class PaymentMethod {
  final int idMetode;
  final String namaMetode;
  final bool status;

  const PaymentMethod({
    required this.idMetode,
    required this.namaMetode,
    required this.status,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        idMetode: json['id_metode'] as int,
        namaMetode: json['nama_metode'] as String,
        status: json['status'] == 1 || json['status'] == true,
      );
}

class Payment {
  final int idPembayaran;
  final int idTransaksi;
  final int idMetode;
  final double totalBayar;
  final double uangDiterima;
  final double kembalian;
  final String? waktuBayar;
  final String status;
  final PaymentMethod? method;

  const Payment({
    required this.idPembayaran,
    required this.idTransaksi,
    required this.idMetode,
    required this.totalBayar,
    required this.uangDiterima,
    required this.kembalian,
    this.waktuBayar,
    required this.status,
    this.method,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        idPembayaran: json['id_pembayaran'] as int,
        idTransaksi: json['id_transaksi'] as int,
        idMetode: json['id_metode'] as int,
        totalBayar: parseDouble(json['total_bayar']),
        uangDiterima: parseDouble(json['uang_diterima']),
        kembalian: parseDouble(json['kembalian']),
        waktuBayar: json['waktu_bayar'] as String?,
        status: json['status'] as String,
        method: json['method'] != null
            ? PaymentMethod.fromJson(json['method'] as Map<String, dynamic>)
            : null,
      );
}

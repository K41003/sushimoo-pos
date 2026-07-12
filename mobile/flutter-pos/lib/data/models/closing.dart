import 'num_util.dart';
class Closing {
  final int idClosing;
  final int idShift;
  final double totalPenjualan;
  final double totalCash;
  final double totalQris;
  final double totalPengeluaran;
  final double saldoAkhir;
  final String? waktuClosing;
  final String status;

  const Closing({
    required this.idClosing,
    required this.idShift,
    required this.totalPenjualan,
    required this.totalCash,
    required this.totalQris,
    required this.totalPengeluaran,
    required this.saldoAkhir,
    this.waktuClosing,
    required this.status,
  });

  factory Closing.fromJson(Map<String, dynamic> json) => Closing(
        idClosing: json['id_closing'] as int,
        idShift: json['id_shift'] as int,
        totalPenjualan: parseDouble(json['total_penjualan']),
        totalCash: parseDouble(json['total_cash']),
        totalQris: parseDouble(json['total_qris']),
        totalPengeluaran: parseDouble(json['total_pengeluaran']),
        saldoAkhir: parseDouble(json['saldo_akhir']),
        waktuClosing: json['waktu_closing'] as String?,
        status: json['status'] as String,
      );
}

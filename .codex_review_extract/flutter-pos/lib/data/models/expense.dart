import 'num_util.dart';
class Expense {
  final int idPengeluaran;
  final int idShift;
  final String kategori;
  final double nominal;
  final String? keterangan;
  final String tanggal;

  const Expense({
    required this.idPengeluaran,
    required this.idShift,
    required this.kategori,
    required this.nominal,
    this.keterangan,
    required this.tanggal,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        idPengeluaran: json['id_pengeluaran'] as int,
        idShift: json['id_shift'] as int,
        kategori: json['kategori'] as String,
        nominal: parseDouble(json['nominal']),
        keterangan: json['keterangan'] as String?,
        tanggal: json['tanggal'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id_pengeluaran': idPengeluaran,
        'id_shift': idShift,
        'kategori': kategori,
        'nominal': nominal,
        'keterangan': keterangan,
        'tanggal': tanggal,
      };
}

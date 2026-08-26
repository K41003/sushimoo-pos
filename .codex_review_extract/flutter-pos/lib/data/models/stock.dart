import 'num_util.dart';
import 'ingredient.dart';

class Stock {
  final int idStok;
  final int idBahan;
  final double jumlah;
  final Ingredient? ingredient;

  const Stock({
    required this.idStok,
    required this.idBahan,
    required this.jumlah,
    this.ingredient,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        idStok: json['id_stok'] as int,
        idBahan: json['id_bahan'] as int,
        jumlah: parseDouble(json['jumlah']),
        ingredient: json['ingredient'] != null
            ? Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>)
            : null,
      );
}

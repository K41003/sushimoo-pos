import 'num_util.dart';
class Ingredient {
  final int idBahan;
  final String namaBahan;
  final String satuan;
  final double minimalStok;

  const Ingredient({
    required this.idBahan,
    required this.namaBahan,
    required this.satuan,
    required this.minimalStok,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        idBahan: json['id_bahan'] as int,
        namaBahan: json['nama_bahan'] as String,
        satuan: json['satuan'] as String,
        minimalStok: parseDouble(json['minimal_stok']),
      );

  Map<String, dynamic> toJson() => {
        'id_bahan': idBahan,
        'nama_bahan': namaBahan,
        'satuan': satuan,
        'minimal_stok': minimalStok,
      };
}

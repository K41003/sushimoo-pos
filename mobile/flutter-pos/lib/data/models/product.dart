import 'num_util.dart';
import 'category.dart';
import 'ingredient.dart';

class Product {
  final int idProduk;
  final int idKategori;
  final String namaProduk;
  final double harga;
  final String? gambar;
  final bool status;
  final Category? category;
  final List<Recipe>? recipes;

  const Product({
    required this.idProduk,
    required this.idKategori,
    required this.namaProduk,
    required this.harga,
    this.gambar,
    required this.status,
    this.category,
    this.recipes,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        idProduk: json['id_produk'] as int,
        idKategori: json['id_kategori'] as int,
        namaProduk: json['nama_produk'] as String,
        harga: parseDouble(json['harga']),
        gambar: json['gambar'] as String?,
        status: json['status'] == 1 || json['status'] == true,
        category: json['category'] != null
            ? Category.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        recipes: (json['recipes'] as List?)
            ?.map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id_produk': idProduk,
        'id_kategori': idKategori,
        'nama_produk': namaProduk,
        'harga': harga,
        'gambar': gambar,
        'status': status ? 1 : 0,
      };
}

class Recipe {
  final int idResep;
  final int idProduk;
  final int idBahan;
  final double qty;
  final Ingredient? ingredient;

  const Recipe({
    required this.idResep,
    required this.idProduk,
    required this.idBahan,
    required this.qty,
    this.ingredient,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        idResep: json['id_resep'] as int,
        idProduk: json['id_produk'] as int,
        idBahan: json['id_bahan'] as int,
        qty: parseDouble(json['qty']),
        ingredient: json['ingredient'] != null
            ? Ingredient.fromJson(json['ingredient'] as Map<String, dynamic>)
            : null,
      );
}

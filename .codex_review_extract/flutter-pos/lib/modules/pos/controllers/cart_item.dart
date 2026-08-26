import '../../../data/models/product.dart';

/// Cart line item for the POS. Holds the product, quantity and an optional note.
class CartItem {
  final Product product;
  int qty;
  String note;

  CartItem({required this.product, this.qty = 1, this.note = ''});

  double get subtotal => product.harga * qty;

  Map<String, dynamic> toPayload() => {
        'id_produk': product.idProduk,
        'qty': qty,
        'harga': product.harga,
        if (note.isNotEmpty) 'catatan': note,
      };
}

import 'num_util.dart';
import 'product.dart';
import 'table.dart';
import 'user.dart';
import 'payment.dart';

class TransactionDetail {
  final int idDetail;
  final int idTransaksi;
  final int idProduk;
  final int qty;
  final double harga;
  final double subtotal;
  final String? catatan;
  final Product? product;

  const TransactionDetail({
    required this.idDetail,
    required this.idTransaksi,
    required this.idProduk,
    required this.qty,
    required this.harga,
    required this.subtotal,
    this.catatan,
    this.product,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) =>
      TransactionDetail(
        idDetail: json['id_detail'] as int,
        idTransaksi: json['id_transaksi'] as int,
        idProduk: json['id_produk'] as int,
        qty: json['qty'] as int,
        harga: parseDouble(json['harga']),
        subtotal: parseDouble(json['subtotal']),
        catatan: json['catatan'] as String?,
        product: json['product'] != null
            ? Product.fromJson(json['product'] as Map<String, dynamic>)
            : null,
      );
}

class Transaction {
  final int idTransaksi;
  final String invoiceNumber;
  final int idShift;
  final int idUser;
  final int idMeja;
  final String tanggal;
  final double total;
  final String status;
  final List<TransactionDetail>? details;
  final TableModel? table;
  final User? user;
  final Payment? payment;

  const Transaction({
    required this.idTransaksi,
    required this.invoiceNumber,
    required this.idShift,
    required this.idUser,
    required this.idMeja,
    required this.tanggal,
    required this.total,
    required this.status,
    this.details,
    this.table,
    this.user,
    this.payment,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        idTransaksi: json['id_transaksi'] as int,
        invoiceNumber: json['invoice_number'] as String,
        idShift: json['id_shift'] as int,
        idUser: json['id_user'] as int,
        idMeja: json['id_meja'] as int,
        tanggal: json['tanggal'] as String,
        total: parseDouble(json['total']),
        status: json['status'] as String,
        details: (json['details'] as List?)
            ?.map((e) => TransactionDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
        table: json['table'] != null
            ? TableModel.fromJson(json['table'] as Map<String, dynamic>)
            : null,
        user: json['user'] != null
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        payment: json['payment'] != null
            ? Payment.fromJson(json['payment'] as Map<String, dynamic>)
            : null,
      );
}

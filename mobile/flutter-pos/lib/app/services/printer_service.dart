import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/transaction.dart';
import '../../data/models/closing.dart';
import '../../data/models/shift.dart';

/// Thermal printer + PDF service for kitchen tickets, customer receipts and
/// the cashier closing report.
class PrinterService extends GetxService {
  static PrinterService get to => Get.find<PrinterService>();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  final RxBool isConnected = false.obs;

  Future<List<BluetoothDevice>> getDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (_) {
      return [];
    }
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
      isConnected.value = true;
      return true;
    } catch (_) {
      isConnected.value = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
    } catch (_) {}
    isConnected.value = false;
  }

  Future<void> _printLines(List<String> lines) async {
    if (!isConnected.value) return;
    for (final line in lines) {
      _bluetooth.printCustom(line, 0, 0);
    }
    _bluetooth.printNewLine();
  }

  Future<void> printKitchenTicket(Transaction trx) async {
    final lines = <String>[
      '=== SUSHIMOO KITCHEN ===',
      'Invoice: ${trx.invoiceNumber}',
      'Table: ${trx.table?.nomorMeja ?? "-"}',
      'Time: ${trx.tanggal}',
      '------------------------',
      ...trx.details
              ?.map((d) => '${d.qty}x ${d.product?.namaProduk ?? d.idProduk}')
              .toList() ??
          [],
      '========================',
    ];
    await _printLines(lines);
  }

  Future<void> printCustomerReceipt(Transaction trx) async {
    final lines = <String>[
      '  SUSHIMOO POS RECEIPT',
      'Invoice: ${trx.invoiceNumber}',
      '------------------------',
      ...?trx.details?.map((d) =>
          '${d.qty}x ${d.product?.namaProduk ?? d.idProduk}  ${d.subtotal.toStringAsFixed(2)}'),
      '------------------------',
      'TOTAL: ${trx.total.toStringAsFixed(2)}',
      if (trx.payment != null) ...[
        'PAID: ${trx.payment!.totalBayar.toStringAsFixed(2)}',
        'CHANGE: ${trx.payment!.kembalian.toStringAsFixed(2)}',
      ],
      '   TERIMA KASIH',
      '========================',
    ];
    await _printLines(lines);
  }

  /// Builds a PDF closing report and opens the system print dialog.
  Future<void> printClosingReport(Closing closing, Shift shift) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
              child: pw.Text('SUSHIMOO POS - CLOSING',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 12),
          pw.Text('Shift: ${shift.idShift}'),
          pw.Text('Waktu: ${closing.waktuClosing ?? "-"}'),
          pw.Divider(),
          _row('Total Penjualan', closing.totalPenjualan),
          _row('Total Cash', closing.totalCash),
          _row('Total QRIS', closing.totalQris),
          _row('Total Pengeluaran', closing.totalPengeluaran),
          pw.Divider(),
          _row('Saldo Akhir', closing.saldoAkhir),
        ],
      ),
    ));
    await Printing.layoutPdf(
        onLayout: (format) async => doc.save());
  }

  pw.Widget _row(String label, double value) =>
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label), pw.Text(value.toStringAsFixed(2))]);
}

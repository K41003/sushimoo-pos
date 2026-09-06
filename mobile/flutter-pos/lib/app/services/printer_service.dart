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
  ///
  /// =====================================================================
  /// UX FIX (design review P0 #4): previously returned `Future<void>` —
  /// if `Printing.layoutPdf` failed or threw (no printer configured, PDF
  /// generation error, OS print dialog dismissed/unavailable), the
  /// exception propagated uncaught and the caller (`ClosingController
  /// .doClosing()`) had no way to distinguish "report printed
  /// successfully" from "printing silently failed" — the cashier would
  /// see a generic "Closing recorded" success toast regardless, with no
  /// indication the physical/PDF report never actually printed.
  ///
  /// Now returns `Future<bool>`: `true` if `layoutPdf` completed without
  /// throwing, `false` if it threw (caught here, not propagated). The
  /// caller can now show an accurate, distinct message for "closing
  /// saved but report failed to print" vs "closing saved and printed".
  ///
  /// NOTE: `Printing.layoutPdf` opens the OS print/share sheet and
  /// resolves once the user dismisses it — it generally does NOT throw
  /// just because the user chose "Cancel" in that sheet (that's normal,
  /// expected user behavior, not a failure). This return value only
  /// distinguishes actual errors (PDF build failure, plugin exception)
  /// from the normal completion path; it can't detect "user cancelled
  /// the OS dialog" as a distinct case since the underlying plugin
  /// doesn't expose that signal separately. If your Closing UX needs to
  /// treat cancellation differently from success, that requires a
  /// `printing` package version/API that exposes the sheet's outcome —
  /// verify against your actual `printing` version if this distinction
  /// becomes important later.
  Future<bool> printClosingReport(Closing closing, Shift shift) async {
    try {
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
      await Printing.layoutPdf(onLayout: (format) async => doc.save());
      return true;
    } catch (e) {
      return false;
    }
  }

  pw.Widget _row(String label, double value) =>
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label), pw.Text(value.toStringAsFixed(2))]);
}

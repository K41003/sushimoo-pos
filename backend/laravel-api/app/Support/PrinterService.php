<?php

namespace App\Support;

use App\Models\Transaction;

class PrinterService
{
    public function kitchenTicket(Transaction $transaction): string
    {
        $lines = [];
        $lines[] = '=== SUSHIMOO KITCHEN ===';
        $lines[] = 'Invoice: ' . $transaction->invoice_number;
        $lines[] = 'Table: ' . optional($transaction->table)->nomor_meja;
        $lines[] = 'Time: ' . $transaction->tanggal;
        $lines[] = '------------------------';
        foreach ($transaction->details as $detail) {
            $lines[] = $detail->qty . 'x ' . optional($detail->product)->nama_produk;
        }
        $lines[] = '=======================';

        return implode("\n", $lines);
    }

    public function customerReceipt(Transaction $transaction): string
    {
        $lines = [];
        $lines[] = '  SUSHIMOO POS RECEIPT';
        $lines[] = 'Invoice: ' . $transaction->invoice_number;
        $lines[] = '------------------------';
        $total = 0;
        foreach ($transaction->details as $detail) {
            $lines[] = $detail->qty . 'x ' . optional($detail->product)->nama_produk
                . '  ' . number_format($detail->subtotal, 2);
            $total += $detail->subtotal;
        }
        $lines[] = '------------------------';
        $lines[] = 'TOTAL: ' . number_format($total, 2);
        if ($transaction->payment) {
            $lines[] = 'PAID: ' . number_format($transaction->payment->total_bayar, 2);
            $lines[] = 'CHANGE: ' . number_format($transaction->payment->kembalian, 2);
        }
        $lines[] = '   TERIMA KASIH';
        $lines[] = '========================';

        return implode("\n", $lines);
    }
}

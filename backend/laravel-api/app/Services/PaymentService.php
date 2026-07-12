<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Transaction;
use App\Repositories\Eloquent\PaymentRepository;
use App\Repositories\Eloquent\TransactionRepository;

class PaymentService
{
    public function __construct(
        private PaymentRepository $payments,
        private TransactionRepository $transactions,
    ) {}

    public function pay(int $transactionId, int $methodId, ?float $uangDiterima): Payment
    {
        $transaction = $this->transactions->findOrFail($transactionId);

        if ($transaction->status === 'paid') {
            throw new \RuntimeException('Transaction already paid.');
        }

        $uangDiterima = $uangDiterima ?? (float) $transaction->total;
        $kembalian = max(0, $uangDiterima - (float) $transaction->total);

        $payment = $this->payments->create([
            'id_transaksi' => $transaction->id_transaksi,
            'id_metode' => $methodId,
            'total_bayar' => $transaction->total,
            'uang_diterima' => $uangDiterima,
            'kembalian' => $kembalian,
            'waktu_bayar' => now(),
            'status' => 'success',
        ]);

        $this->transactions->update($transaction, ['status' => 'paid']);

        return $payment->load('transaction', 'method');
    }
}

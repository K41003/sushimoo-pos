<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\PaymentMethod;
use App\Models\Transaction;
use App\Repositories\Eloquent\PaymentRepository;
use Illuminate\Support\Facades\DB;

class PaymentService
{
    public function __construct(
        private PaymentRepository $payments,
    ) {}

    public function pay(int $transactionId, int $methodId, ?float $uangDiterima): Payment
    {
        return DB::transaction(function () use ($transactionId, $methodId, $uangDiterima) {
            $transaction = Transaction::query()
                ->whereKey($transactionId)
                ->lockForUpdate()
                ->firstOrFail();

            if ($transaction->status === 'paid') {
                throw new \RuntimeException('Transaction already paid.');
            }

            $method = PaymentMethod::findOrFail($methodId);
            $total = (float) $transaction->total;
            $uangDiterima = $uangDiterima ?? $total;

            if (strtolower($method->nama_metode) === 'cash' && $uangDiterima < $total) {
                throw new \RuntimeException('Received cash is less than transaction total.');
            }

            $kembalian = max(0, $uangDiterima - $total);

            $payment = $this->payments->create([
                'id_transaksi' => $transaction->id_transaksi,
                'id_metode' => $methodId,
                'total_bayar' => $transaction->total,
                'uang_diterima' => $uangDiterima,
                'kembalian' => $kembalian,
                'waktu_bayar' => now(),
                'status' => 'success',
            ]);

            $transaction->update(['status' => 'paid']);

            return $payment->load('transaction', 'method');
        });
    }
}

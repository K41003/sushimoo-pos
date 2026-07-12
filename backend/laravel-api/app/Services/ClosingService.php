<?php

namespace App\Services;

use App\Models\Closing;
use App\Models\PaymentMethod;
use App\Models\Shift;
use App\Repositories\Eloquent\ClosingRepository;
use App\Repositories\Eloquent\ExpenseRepository;
use App\Repositories\Eloquent\TransactionRepository;

class ClosingService
{
    public function __construct(
        private TransactionRepository $transactions,
        private ExpenseRepository $expenses,
        private ClosingRepository $closings,
    ) {}

    public function computeAndStore(Shift $shift): Closing
    {
        $transactions = $shift->transactions()
            ->where('status', 'paid')
            ->with('payment')
            ->get();

        $totalPenjualan = $transactions->sum('total');
        $totalCash = 0;
        $totalQris = 0;

        $cashMethod = PaymentMethod::where('nama_metode', 'Cash')->value('id_metode');
        $qrisMethod = PaymentMethod::where('nama_metode', 'QRIS')->value('id_metode');

        foreach ($transactions as $trx) {
            $methodId = optional($trx->payment)->id_metode;
            if ($methodId === $cashMethod) {
                $totalCash += (float) $trx->total;
            } elseif ($methodId === $qrisMethod) {
                $totalQris += (float) $trx->total;
            }
        }

        $totalPengeluaran = $shift->expenses()->sum('nominal');
        $saldoAkhir = (float) $shift->petty_cash + $totalCash - $totalPengeluaran;

        return $this->closings->create([
            'id_shift' => $shift->id_shift,
            'total_penjualan' => $totalPenjualan,
            'total_cash' => $totalCash,
            'total_qris' => $totalQris,
            'total_pengeluaran' => $totalPengeluaran,
            'saldo_akhir' => $saldoAkhir,
            'waktu_closing' => now(),
            'status' => 'success',
        ]);
    }

    public function history(int $perPage = 15)
    {
        return $this->closings->history($perPage);
    }
}

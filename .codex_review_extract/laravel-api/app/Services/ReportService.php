<?php

namespace App\Services;

use App\Models\PaymentMethod;
use App\Models\Transaction;
use App\Repositories\Eloquent\ExpenseRepository;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\TransactionRepository;

class ReportService
{
    public function __construct(
        private TransactionRepository $transactions,
        private ExpenseRepository $expenses,
        private ProductRepository $products,
    ) {}

    public function daily(?string $date = null): array
    {
        $date = $date ?? now()->toDateString();
        $transactions = Transaction::whereDate('tanggal', $date)
            ->where('status', 'paid')
            ->with('payment')
            ->get();

        $cashMethod = PaymentMethod::where('nama_metode', 'Cash')->value('id_metode');
        $qrisMethod = PaymentMethod::where('nama_metode', 'QRIS')->value('id_metode');

        $cash = 0;
        $qris = 0;
        foreach ($transactions as $t) {
            $m = optional($t->payment)->id_metode;
            if ($m === $cashMethod) {
                $cash += (float) $t->total;
            } elseif ($m === $qrisMethod) {
                $qris += (float) $t->total;
            }
        }

        return [
            'date' => $date,
            'sales' => $transactions->sum('total'),
            'orders' => $transactions->count(),
            'cash' => $cash,
            'qris' => $qris,
            'expenses' => $this->expenses->query()
                ->whereDate('tanggal', $date)->sum('nominal'),
            'transactions' => $transactions,
        ];
    }

    public function monthly(?int $month = null, ?int $year = null): array
    {
        $month = $month ?? (int) now()->month;
        $year = $year ?? (int) now()->year;

        $transactions = Transaction::whereMonth('tanggal', $month)
            ->whereYear('tanggal', $year)
            ->where('status', 'paid')
            ->with('payment')
            ->get();

        $byDay = [];
        foreach ($transactions as $t) {
            $day = $t->tanggal->format('Y-m-d');
            $byDay[$day] = ($byDay[$day] ?? 0) + (float) $t->total;
        }

        return [
            'month' => $month,
            'year' => $year,
            'total' => $transactions->sum('total'),
            'orders' => $transactions->count(),
            'byDay' => $byDay,
        ];
    }

    public function statistics(?string $from = null, ?string $to = null): array
    {
        $from = $from ?? now()->startOfMonth()->toDateString();
        $to = $to ?? now()->toDateString();

        $transactions = Transaction::whereBetween('tanggal', [$from, $to])
            ->where('status', 'paid')
            ->with('details.product', 'payment')
            ->get();

        $salesTrend = [];
        foreach ($transactions as $t) {
            $day = $t->tanggal->format('Y-m-d');
            $salesTrend[$day] = ($salesTrend[$day] ?? 0) + (float) $t->total;
        }

        $productAgg = [];
        foreach ($transactions as $t) {
            foreach ($t->details as $d) {
                $pid = $d->id_produk;
                $productAgg[$pid] = ($productAgg[$pid] ?? 0) + $d->qty;
            }
        }

        $topProducts = collect($productAgg)
            ->sortDesc()
            ->take(5)
            ->map(fn ($qty, $pid) => [
                'id_produk' => (int) $pid,
                'nama_produk' => optional(\App\Models\Product::find($pid))->nama_produk,
                'qty' => $qty,
            ])
            ->values();

        return [
            'from' => $from,
            'to' => $to,
            'salesTrend' => $salesTrend,
            'topProducts' => $topProducts,
            'cashflow' => [
                'sales' => $transactions->sum('total'),
                'expenses' => $this->expenses->query()
                    ->whereBetween('tanggal', [$from, $to])->sum('nominal'),
            ],
        ];
    }

    public function last7Days(): array
    {
        $days = [];
        $totals = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i)->toDateString();
            $days[] = $date;
            $totals[] = (float) Transaction::whereDate('tanggal', $date)
                ->where('status', 'paid')->sum('total');
        }

        return ['days' => $days, 'totals' => $totals];
    }
}

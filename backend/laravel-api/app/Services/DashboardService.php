<?php

namespace App\Services;

use App\Models\Transaction;
use App\Repositories\Eloquent\ExpenseRepository;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\ShiftRepository;
use App\Repositories\Eloquent\TransactionRepository;

class DashboardService
{
    public function __construct(
        private TransactionRepository $transactions,
        private ProductRepository $products,
        private ExpenseRepository $expenses,
        private ShiftRepository $shifts,
        private ReportService $reports,
    ) {}

    public function admin(): array
    {
        $stats = $this->reports->statistics();

        return [
            'totalSales' => (float) Transaction::where('status', 'paid')->sum('total'),
            'transactions' => Transaction::count(),
            'products' => $this->products->all()->count(),
            'expenses' => (float) $this->expenses->query()->sum('nominal'),
            'salesTrend' => $stats['salesTrend'],
            'topProducts' => $stats['topProducts'],
        ];
    }

    public function cashier(int $userId): array
    {
        $shift = $this->shifts->activeForUser($userId);
        $today = now()->toDateString();

        $todaySales = (float) Transaction::where('id_user', $userId)
            ->whereDate('tanggal', $today)
            ->where('status', 'paid')
            ->sum('total');

        $todayOrders = Transaction::where('id_user', $userId)
            ->whereDate('tanggal', $today)
            ->count();

        return [
            'currentShift' => $shift,
            'salesToday' => $todaySales,
            'ordersToday' => $todayOrders,
        ];
    }
}

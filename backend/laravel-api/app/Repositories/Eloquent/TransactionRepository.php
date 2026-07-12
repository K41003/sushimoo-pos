<?php

namespace App\Repositories\Eloquent;

use App\Models\Transaction;

class TransactionRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Transaction());
    }

    public function search(?string $status, ?int $tableId, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->with(['table', 'details.product', 'user'])
            ->when($status, fn ($query) => $query->where('status', $status))
            ->when($tableId, fn ($query) => $query->where('id_meja', $tableId))
            ->latest('tanggal')
            ->paginate($perPage);
    }

    public function filterByDate(string $from, string $to)
    {
        return $this->model->newQuery()
            ->with(['details.product', 'payment'])
            ->whereBetween('tanggal', [$from, $to])
            ->get();
    }
}

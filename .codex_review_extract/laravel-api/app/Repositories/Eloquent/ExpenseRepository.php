<?php

namespace App\Repositories\Eloquent;

use App\Models\Expense;

class ExpenseRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Expense());
    }

    public function byShift(int $shiftId, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->where('id_shift', $shiftId)
            ->latest('tanggal')
            ->paginate($perPage);
    }
}

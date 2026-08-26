<?php

namespace App\Repositories\Eloquent;

use App\Models\Table;

class TableRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Table());
    }

    public function search(?string $status, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->when($status, fn ($query) => $query->where('status', $status))
            ->paginate($perPage);
    }
}

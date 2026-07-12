<?php

namespace App\Repositories\Eloquent;

use App\Models\Closing;

class ClosingRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Closing());
    }

    public function history(int $perPage = 15)
    {
        return $this->model->newQuery()
            ->with('shift.user')
            ->latest('waktu_closing')
            ->paginate($perPage);
    }
}

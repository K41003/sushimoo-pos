<?php

namespace App\Repositories\Eloquent;

use App\Models\Shift;

class ShiftRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Shift());
    }

    public function activeForUser(int $userId): ?Shift
    {
        return $this->model->newQuery()
            ->where('id_user', $userId)
            ->where('status', 'open')
            ->latest('open_time')
            ->first();
    }

    public function history(int $perPage = 15)
    {
        return $this->model->newQuery()
            ->with('user')
            ->latest('open_time')
            ->paginate($perPage);
    }

    public function close(Shift $shift, array $data): bool
    {
        return $shift->update($data);
    }
}

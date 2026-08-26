<?php

namespace App\Repositories\Eloquent;

use App\Models\ActivityLog;

class ActivityLogRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new ActivityLog());
    }

    public function log(int $userId, string $activity, ?string $ip = null): void
    {
        $this->model->newQuery()->create([
            'id_user' => $userId,
            'aktivitas' => $activity,
            'ip_address' => $ip,
            'created_at' => now(),
        ]);
    }
}

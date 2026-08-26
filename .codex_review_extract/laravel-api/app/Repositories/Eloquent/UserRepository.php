<?php

namespace App\Repositories\Eloquent;

use App\Models\User;

class UserRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new User());
    }

    public function findByUsername(string $username): ?User
    {
        return $this->model->newQuery()->where('username', $username)->first();
    }

    public function activeUsers(): \Illuminate\Database\Eloquent\Collection
    {
        return $this->model->newQuery()->where('status', 1)->get();
    }
}

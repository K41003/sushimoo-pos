<?php

namespace App\Repositories\Eloquent;

use App\Models\Role;

class RoleRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Role());
    }
}

<?php

namespace App\Repositories\Eloquent;

use App\Models\PettyCash;

class PettyCashRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new PettyCash());
    }
}

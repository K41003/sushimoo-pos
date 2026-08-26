<?php

namespace App\Repositories\Eloquent;

use App\Models\PaymentMethod;

class PaymentMethodRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new PaymentMethod());
    }

    public function active(): \Illuminate\Database\Eloquent\Collection
    {
        return $this->model->newQuery()->where('status', 1)->get();
    }
}

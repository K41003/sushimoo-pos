<?php

namespace App\Repositories\Eloquent;

use App\Models\Payment;

class PaymentRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Payment());
    }
}

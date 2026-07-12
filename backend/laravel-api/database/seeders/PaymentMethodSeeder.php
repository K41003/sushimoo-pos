<?php

namespace Database\Seeders;

use App\Models\PaymentMethod;
use Illuminate\Database\Seeder;

class PaymentMethodSeeder extends Seeder
{
    public function run(): void
    {
        if (PaymentMethod::count() > 0) {
            return;
        }

        PaymentMethod::insert([
            ['nama_metode' => 'Cash', 'status' => 1],
            ['nama_metode' => 'QRIS', 'status' => 1],
            ['nama_metode' => 'Debit', 'status' => 1],
        ]);
    }
}

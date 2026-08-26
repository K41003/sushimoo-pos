<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            PaymentMethodSeeder::class,
            TableSeeder::class,
            UserSeeder::class,
            CategorySeeder::class,
            ProductSeeder::class,
            IngredientSeeder::class,
            StockSeeder::class,
        ]);
    }
}

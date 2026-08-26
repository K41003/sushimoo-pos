<?php

namespace Database\Seeders;

use App\Models\Ingredient;
use App\Models\Stock;
use Illuminate\Database\Seeder;

class StockSeeder extends Seeder
{
    public function run(): void
    {
        $stocks = [
            'Beras' => 25,
            'Ayam Fillet' => 8,
            'Tepung Terigu' => 12,
            'Telur' => 60,
            'Sayur Hijau' => 15,
            'Daging Sapi' => 4,
            'Udang' => 3,
            'Keju' => 800,
            'Matcha Powder' => 350,
            'Nor i (Rumput Laut)' => 120,
        ];

        foreach ($stocks as $name => $jumlah) {
            $ingredient = Ingredient::where('nama_bahan', $name)->first();
            if (!$ingredient) {
                continue;
            }
            Stock::updateOrCreate(
                ['id_bahan' => $ingredient->id_bahan],
                [
                    'id_bahan' => $ingredient->id_bahan,
                    'jumlah' => $jumlah,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
        }
    }
}

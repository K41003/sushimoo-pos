<?php

namespace Database\Seeders;

use App\Models\Ingredient;
use Illuminate\Database\Seeder;

class IngredientSeeder extends Seeder
{
    public function run(): void
    {
        $ingredients = [
            ['nama_bahan' => 'Beras', 'satuan' => 'kg', 'minimal_stok' => 10],
            ['nama_bahan' => 'Ayam Fillet', 'satuan' => 'kg', 'minimal_stok' => 5],
            ['nama_bahan' => 'Tepung Terigu', 'satuan' => 'kg', 'minimal_stok' => 5],
            ['nama_bahan' => 'Telur', 'satuan' => 'butir', 'minimal_stok' => 30],
            ['nama_bahan' => 'Sayur Hijau', 'satuan' => 'ikat', 'minimal_stok' => 10],
            ['nama_bahan' => 'Daging Sapi', 'satuan' => 'kg', 'minimal_stok' => 3],
            ['nama_bahan' => 'Udang', 'satuan' => 'kg', 'minimal_stok' => 2],
            ['nama_bahan' => 'Keju', 'satuan' => 'gram', 'minimal_stok' => 500],
            ['nama_bahan' => 'Matcha Powder', 'satuan' => 'gram', 'minimal_stok' => 200],
            ['nama_bahan' => 'Nor i (Rumput Laut)', 'satuan' => 'lembar', 'minimal_stok' => 50],
        ];

        foreach ($ingredients as $i) {
            Ingredient::updateOrCreate(
                ['nama_bahan' => $i['nama_bahan']],
                array_merge($i, ['created_at' => now(), 'updated_at' => now()])
            );
        }
    }
}

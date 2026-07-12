<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['nama_kategori' => 'Makanan Utama', 'deskripsi' => 'Menu utama sushi, donburi, dan noodle', 'status' => 1],
            ['nama_kategori' => 'Makanan Ringan', 'deskripsi' => 'Appetizer dan camilan', 'status' => 1],
            ['nama_kategori' => 'Minuman', 'deskripsi' => 'Minuman dingin dan hangat', 'status' => 1],
            ['nama_kategori' => 'Dessert', 'deskripsi' => 'Penutup dan hidangan manis', 'status' => 1],
            ['nama_kategori' => 'Paket Hemat', 'deskripsi' => 'Paket kombo hemat', 'status' => 1],
        ];

        foreach ($categories as $c) {
            Category::updateOrCreate(
                ['nama_kategori' => $c['nama_kategori']],
                array_merge($c, ['created_at' => now(), 'updated_at' => now()])
            );
        }
    }
}

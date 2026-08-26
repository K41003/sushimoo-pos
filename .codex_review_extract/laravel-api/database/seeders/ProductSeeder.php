<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $data = [
            'Makanan Utama' => [
                ['nama_produk' => 'Sushi Salmon Roll', 'harga' => 45000],
                ['nama_produk' => 'Sushi Tuna Roll', 'harga' => 48000],
                ['nama_produk' => 'Donburi Chicken Katsu', 'harga' => 38000],
                ['nama_produk' => 'Ramen Shoyu', 'harga' => 42000],
                ['nama_produk' => 'Udon Seafood', 'harga' => 40000],
                ['nama_produk' => 'Temaki Ebi', 'harga' => 35000],
            ],
            'Makanan Ringan' => [
                ['nama_produk' => 'Edamame', 'harga' => 18000],
                ['nama_produk' => 'Gyoza (5 pcs)', 'harga' => 28000],
                ['nama_produk' => 'Takoyaki (4 pcs)', 'harga' => 25000],
                ['nama_produk' => 'Karaage', 'harga' => 30000],
            ],
            'Minuman' => [
                ['nama_produk' => 'Matcha Latte', 'harga' => 22000],
                ['nama_produk' => 'Ocha (Teh Hijau)', 'harga' => 12000],
                ['nama_produk' => 'Coca Cola', 'harga' => 10000],
                ['nama_produk' => 'Juice Jeruk', 'harga' => 18000],
                ['nama_produk' => 'Americano Ice', 'harga' => 20000],
            ],
            'Dessert' => [
                ['nama_produk' => 'Mochi Ice Cream', 'harga' => 20000],
                ['nama_produk' => 'Cheesecake', 'harga' => 26000],
                ['nama_produk' => 'Dorayaki', 'harga' => 15000],
            ],
            'Paket Hemat' => [
                ['nama_produk' => 'Paket Sushi Family', 'harga' => 150000],
                ['nama_produk' => 'Paket Ramen + Drink', 'harga' => 55000],
                ['nama_produk' => 'Paket Bento Kombo', 'harga' => 65000],
            ],
        ];

        foreach ($data as $categoryName => $products) {
            $category = Category::where('nama_kategori', $categoryName)->first();
            if (!$category) {
                continue;
            }
            foreach ($products as $p) {
                Product::updateOrCreate(
                    ['nama_produk' => $p['nama_produk'], 'id_kategori' => $category->id_kategori],
                    [
                        'id_kategori' => $category->id_kategori,
                        'nama_produk' => $p['nama_produk'],
                        'harga' => $p['harga'],
                        'gambar' => null,
                        'status' => 1,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]
                );
            }
        }
    }
}

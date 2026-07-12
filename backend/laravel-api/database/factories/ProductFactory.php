<?php

namespace Database\Factories;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    protected $model = Product::class;

    public function definition(): array
    {
        return [
            'id_kategori' => Category::factory(),
            'nama_produk' => fake()->words(2, true),
            'harga' => fake()->numberBetween(10000, 100000),
            'gambar' => null,
            'status' => 1,
        ];
    }
}

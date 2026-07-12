<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class CategoryFactory extends Factory
{
    protected $model = \App\Models\Category::class;

    public function definition(): array
    {
        return [
            'nama_kategori' => fake()->unique()->word(),
            'deskripsi' => fake()->sentence(),
            'status' => 1,
        ];
    }
}

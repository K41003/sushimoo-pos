<?php

namespace App\Services;

use App\Models\Recipe;
use App\Repositories\Eloquent\ProductRepository;

class ProductService
{
    public function __construct(private ProductRepository $repository) {}

    public function list(?string $q, ?int $categoryId, int $perPage = 15)
    {
        return $this->repository->search($q, $categoryId, $perPage);
    }

    public function find(int $id)
    {
        return $this->repository->findOrFail($id)->load('recipes.ingredient');
    }

    public function create(array $data)
    {
        $recipes = $data['recipes'] ?? [];
        unset($data['recipes']);

        $product = $this->repository->create($data);

        if (! empty($recipes)) {
            foreach ($recipes as $recipe) {
                $product->recipes()->create($recipe);
            }
        }

        return $product->load('recipes.ingredient', 'category');
    }

    public function update(int $id, array $data)
    {
        $model = $this->repository->findOrFail($id);
        $recipes = $data['recipes'] ?? null;
        unset($data['recipes']);

        $this->repository->update($model, $data);

        if (! is_null($recipes)) {
            $model->recipes()->delete();
            foreach ($recipes as $recipe) {
                $model->recipes()->create($recipe);
            }
        }

        return $model->load('recipes.ingredient', 'category');
    }

    public function delete(int $id): bool
    {
        $model = $this->repository->findOrFail($id);

        return $this->repository->delete($model);
    }
}

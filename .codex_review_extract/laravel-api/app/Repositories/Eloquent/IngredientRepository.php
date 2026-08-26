<?php

namespace App\Repositories\Eloquent;

use App\Models\Ingredient;

class IngredientRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Ingredient());
    }

    public function search(string $q, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->when($q, fn ($query) => $query->where('nama_bahan', 'like', "%{$q}%"))
            ->paginate($perPage);
    }
}

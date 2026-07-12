<?php

namespace App\Repositories\Eloquent;

use App\Models\Stock;

class StockRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Stock());
    }

    public function search(string $q, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->with('ingredient')
            ->when($q, fn ($query) => $query->whereHas('ingredient', fn ($q2) => $q2->where('nama_bahan', 'like', "%{$q}%")))
            ->paginate($perPage);
    }

    public function byIngredient(int $ingredientId): ?Stock
    {
        return $this->model->newQuery()->where('id_bahan', $ingredientId)->first();
    }
}

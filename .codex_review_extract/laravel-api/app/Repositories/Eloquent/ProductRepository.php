<?php

namespace App\Repositories\Eloquent;

use App\Models\Product;

class ProductRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Product());
    }

    public function search(?string $q, ?int $categoryId, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->with('category')
            ->when($q, fn ($query) => $query->where('nama_produk', 'like', "%{$q}%"))
            ->when($categoryId, fn ($query) => $query->where('id_kategori', $categoryId))
            ->paginate($perPage);
    }
}

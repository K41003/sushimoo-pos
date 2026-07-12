<?php

namespace App\Repositories\Eloquent;

use App\Models\Category;

class CategoryRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new Category());
    }

    public function search(string $q, int $perPage = 15)
    {
        return $this->model->newQuery()
            ->when($q, fn ($query) => $query->where('nama_kategori', 'like', "%{$q}%"))
            ->paginate($perPage);
    }
}

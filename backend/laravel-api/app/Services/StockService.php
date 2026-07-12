<?php

namespace App\Services;

use App\Models\Stock;
use App\Repositories\Eloquent\StockRepository;

class StockService
{
    public function __construct(private StockRepository $repository) {}

    public function list(string $q = '', int $perPage = 15)
    {
        return $this->repository->search($q, $perPage);
    }

    public function find(int $id)
    {
        return $this->repository->findOrFail($id)->load('ingredient');
    }

    public function create(array $data)
    {
        $existing = $this->repository->byIngredient((int) $data['id_bahan']);

        if ($existing) {
            $existing->jumlah = (float) $existing->jumlah + (float) $data['jumlah'];
            $existing->save();

            return $existing->load('ingredient');
        }

        return $this->repository->create($data)->load('ingredient');
    }

    public function update(int $id, array $data)
    {
        $model = $this->repository->findOrFail($id);
        $this->repository->update($model, $data);

        return $model->load('ingredient');
    }

    public function delete(int $id): bool
    {
        $model = $this->repository->findOrFail($id);

        return $this->repository->delete($model);
    }
}

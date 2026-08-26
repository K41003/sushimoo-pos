<?php

namespace App\Services;

use App\Repositories\Eloquent\IngredientRepository;

class IngredientService
{
    public function __construct(private IngredientRepository $repository) {}

    public function list(string $q = '', int $perPage = 15)
    {
        return $this->repository->search($q, $perPage);
    }

    public function find(int $id)
    {
        return $this->repository->findOrFail($id);
    }

    public function create(array $data)
    {
        return $this->repository->create($data);
    }

    public function update(int $id, array $data)
    {
        $model = $this->repository->findOrFail($id);
        $this->repository->update($model, $data);

        return $model;
    }

    public function delete(int $id): bool
    {
        $model = $this->repository->findOrFail($id);

        return $this->repository->delete($model);
    }
}

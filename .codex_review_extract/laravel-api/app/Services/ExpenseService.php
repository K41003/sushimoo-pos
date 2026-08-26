<?php

namespace App\Services;

use App\Repositories\Eloquent\ExpenseRepository;

class ExpenseService
{
    public function __construct(private ExpenseRepository $repository) {}

    public function list(int $shiftId, int $perPage = 15)
    {
        return $this->repository->byShift($shiftId, $perPage);
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

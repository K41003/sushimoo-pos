<?php

namespace App\Http\Controllers\Ingredient;

use App\Http\Controllers\Controller;
use App\Http\Requests\Ingredient\IngredientRequest;
use App\Services\IngredientService;
use Illuminate\Http\JsonResponse;

class IngredientController extends Controller
{
    public function __construct(private IngredientService $service) {}

    public function index(): JsonResponse
    {
        $q = request()->query('q', '');
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($q, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function store(IngredientRequest $request): JsonResponse
    {
        return $this->created($this->service->create($request->validated()), 'Ingredient created');
    }

    public function update(int $id, IngredientRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Ingredient updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Ingredient deleted');
    }
}

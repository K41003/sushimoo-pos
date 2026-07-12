<?php

namespace App\Http\Controllers\Stock;

use App\Http\Controllers\Controller;
use App\Http\Requests\Stock\StockRequest;
use App\Services\StockService;
use Illuminate\Http\JsonResponse;

class StockController extends Controller
{
    public function __construct(private StockService $service) {}

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

    public function store(StockRequest $request): JsonResponse
    {
        return $this->created($this->service->create($request->validated()), 'Stock adjustment recorded');
    }

    public function update(int $id, StockRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Stock updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Stock deleted');
    }
}

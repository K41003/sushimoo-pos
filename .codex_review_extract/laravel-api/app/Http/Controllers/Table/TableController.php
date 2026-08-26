<?php

namespace App\Http\Controllers\Table;

use App\Http\Controllers\Controller;
use App\Http\Requests\Table\TableRequest;
use App\Services\TableService;
use Illuminate\Http\JsonResponse;

class TableController extends Controller
{
    public function __construct(private TableService $service) {}

    public function index(): JsonResponse
    {
        $status = request()->query('status');
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($status, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function store(TableRequest $request): JsonResponse
    {
        return $this->created($this->service->create($request->validated()), 'Table created');
    }

    public function update(int $id, TableRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Table updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Table deleted');
    }
}

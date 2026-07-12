<?php

namespace App\Http\Controllers\Expense;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expense\ExpenseRequest;
use App\Services\ExpenseService;
use Illuminate\Http\JsonResponse;

class ExpenseController extends Controller
{
    public function __construct(private ExpenseService $service) {}

    public function index(): JsonResponse
    {
        $shiftId = (int) request()->query('id_shift');
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($shiftId, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function store(ExpenseRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['id_shift'] = (int) ($request->input('id_shift') ?? auth()->user()->shifts()->where('status', 'open')->value('id_shift'));
        $data['tanggal'] = $data['tanggal'] ?? now();

        return $this->created($this->service->create($data), 'Expense recorded');
    }

    public function update(int $id, ExpenseRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Expense updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Expense deleted');
    }
}

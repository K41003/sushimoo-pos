<?php

namespace App\Http\Controllers\Transaction;

use App\Http\Controllers\Controller;
use App\Http\Requests\Transaction\StoreTransactionRequest;
use App\Http\Requests\Transaction\UpdateTransactionRequest;
use App\Http\Requests\Transaction\VoidTransactionRequest;
use App\Services\TransactionService;
use Illuminate\Http\JsonResponse;

class TransactionController extends Controller
{
    public function __construct(private TransactionService $service) {}

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        try {
            $transaction = $this->service->create($request->validated(), auth()->id());
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->created($transaction, 'Transaction created');
    }

    public function index(): JsonResponse
    {
        $status = request()->query('status');
        $tableId = request()->query('id_meja') ? (int) request()->query('id_meja') : null;
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($status, $tableId, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function update(int $id, UpdateTransactionRequest $request): JsonResponse
    {
        try {
            $transaction = $this->service->update($id, $request->validated());
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->ok($transaction, 'Transaction updated');
    }

    public function void(int $id, VoidTransactionRequest $request): JsonResponse
    {
        $transaction = $this->service->void($id, (string) $request->input('alasan', ''));

        return $this->ok($transaction, 'Transaction voided');
    }
}

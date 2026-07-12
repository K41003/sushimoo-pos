<?php

namespace App\Services;

use App\Models\Shift;
use App\Models\Transaction;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\TableRepository;
use App\Repositories\Eloquent\TransactionDetailRepository;
use App\Repositories\Eloquent\TransactionRepository;
use Illuminate\Support\Facades\DB;

class TransactionService
{
    public function __construct(
        private TransactionRepository $transactions,
        private TransactionDetailRepository $details,
        private TableRepository $tables,
        private ProductRepository $products,
    ) {}

    private function invoiceNumber(): string
    {
        return 'INV-' . now()->format('Ymd') . '-' . str_pad((string) random_int(1, 9999), 4, '0', STR_PAD_LEFT);
    }

    private function computeItems(array $items): array
    {
        $total = 0;
        $prepared = [];
        $productIds = collect($items)->pluck('id_produk')->map(fn ($id) => (int) $id)->unique()->values();
        $products = $this->products->query()
            ->whereIn('id_produk', $productIds)
            ->get()
            ->keyBy('id_produk');

        foreach ($items as $item) {
            $qty = (int) $item['qty'];
            $productId = (int) $item['id_produk'];
            $product = $products->get($productId);
            if (! $product || ! $product->status) {
                throw new \RuntimeException('Product is unavailable.');
            }

            $harga = (float) $product->harga;
            $subtotal = $qty * $harga;
            $total += $subtotal;
            $prepared[] = [
                'id_produk' => $productId,
                'qty' => $qty,
                'harga' => $harga,
                'subtotal' => $subtotal,
            ];
        }

        return [$prepared, $total];
    }

    public function create(array $data, int $userId): Transaction
    {
        return DB::transaction(function () use ($data, $userId) {
            $shift = Shift::where('id_user', $userId)->where('status', 'open')->first();
            if (! $shift) {
                throw new \RuntimeException('No active shift for cashier.');
            }

            [$prepared, $total] = $this->computeItems($data['items']);

            $transaction = $this->transactions->create([
                'invoice_number' => $this->invoiceNumber(),
                'id_shift' => $shift->id_shift,
                'id_user' => $userId,
                'id_meja' => (int) $data['id_meja'],
                'tanggal' => $data['tanggal'] ?? now(),
                'total' => $total,
                'status' => 'pending',
            ]);

            $this->details->createMany($transaction->id_transaksi, $prepared);

            $table = $this->tables->find((int) $data['id_meja']);
            if ($table) {
                $this->tables->update($table, ['status' => 'occupied']);
            }

            return $transaction->load('details.product', 'table', 'user');
        });
    }

    public function list(?string $status, ?int $tableId, int $perPage = 15)
    {
        return $this->transactions->search($status, $tableId, $perPage);
    }

    public function find(int $id)
    {
        return $this->transactions->findOrFail($id)->load('details.product', 'table', 'user', 'payment');
    }

    public function update(int $id, array $data): Transaction
    {
        return DB::transaction(function () use ($id, $data) {
            $transaction = $this->transactions->findOrFail($id);
            if ($transaction->status === 'paid') {
                throw new \RuntimeException('Paid transaction cannot be updated.');
            }

            [$prepared, $total] = $this->computeItems($data['items']);
            $this->details->deleteForTransaction($transaction->id_transaksi);
            $this->details->createMany($transaction->id_transaksi, $prepared);

            $this->transactions->update($transaction, ['total' => $total]);

            return $transaction->load('details.product', 'table', 'user');
        });
    }

    public function void(int $id, string $reason): Transaction
    {
        return DB::transaction(function () use ($id) {
            $transaction = $this->transactions->findOrFail($id);
            $this->transactions->update($transaction, ['status' => 'cancelled']);

            $table = $this->tables->find($transaction->id_meja);
            if ($table) {
                $this->tables->update($table, ['status' => 'available']);
            }

            return $transaction->load('details.product', 'table', 'user');
        });
    }
}

<?php

namespace App\Services;

use App\Models\Shift;
use App\Models\Transaction;
use App\Repositories\Eloquent\ActivityLogRepository;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\TableRepository;
use App\Repositories\Eloquent\TransactionDetailRepository;
use App\Repositories\Eloquent\TransactionRepository;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class TransactionService
{
    public function __construct(
        private TransactionRepository $transactions,
        private TransactionDetailRepository $details,
        private TableRepository $tables,
        private ProductRepository $products,
        private ActivityLogRepository $activityLogs,
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
        }, 3);
    }

    public function createWithRetry(array $data, int $userId): Transaction
    {
        $attempts = 0;

        do {
            try {
                return $this->create($data, $userId);
            } catch (QueryException $e) {
                $attempts++;
                if (! $this->isDuplicateInvoiceException($e) || $attempts >= 3) {
                    throw $e;
                }
            }
        } while ($attempts < 3);

        throw new \RuntimeException('Unable to create a unique invoice number.');
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

    public function void(int $id, string $reason, ?int $userId = null, ?string $ip = null): Transaction
    {
        return DB::transaction(function () use ($id, $reason, $userId, $ip) {
            $transaction = Transaction::query()
                ->whereKey($id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($transaction->status === 'paid') {
                throw new \RuntimeException('Paid transaction cannot be voided.');
            }

            if ($transaction->status === 'cancelled') {
                throw new \RuntimeException('Transaction already voided.');
            }

            $updates = ['status' => 'cancelled'];
            if (Schema::hasColumn('transaksi', 'void_reason')) {
                $updates['void_reason'] = $reason;
            }
            if (Schema::hasColumn('transaksi', 'voided_by')) {
                $updates['voided_by'] = $userId;
            }
            if (Schema::hasColumn('transaksi', 'voided_at')) {
                $updates['voided_at'] = now();
            }

            $this->transactions->update($transaction, $updates);

            $table = $this->tables->find($transaction->id_meja);
            $hasOtherOpenTransactions = Transaction::query()
                ->where('id_meja', $transaction->id_meja)
                ->where('id_transaksi', '!=', $transaction->id_transaksi)
                ->where('status', 'pending')
                ->exists();

            if ($table && ! $hasOtherOpenTransactions) {
                $this->tables->update($table, ['status' => 'available']);
            }

            if ($userId !== null) {
                $this->activityLogs->log(
                    $userId,
                    sprintf(
                        'Void transaction %s. Reason: %s',
                        $transaction->invoice_number,
                        $reason !== '' ? $reason : '-'
                    ),
                    $ip
                );
            }

            return $transaction->load('details.product', 'table', 'user');
        }, 3);
    }

    private function isDuplicateInvoiceException(QueryException $e): bool
    {
        $sqlState = (string) ($e->errorInfo[0] ?? '');
        $driverCode = (string) ($e->errorInfo[1] ?? '');
        $message = strtolower($e->getMessage());

        return $sqlState === '23000'
            && ($driverCode === '1062' || str_contains($message, 'invoice_number'));
    }
}

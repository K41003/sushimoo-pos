<?php

namespace App\Repositories\Eloquent;

use App\Models\TransactionDetail;

class TransactionDetailRepository extends BaseRepository
{
    public function __construct()
    {
        parent::__construct(new TransactionDetail());
    }

    public function createMany(int $transactionId, array $items): void
    {
        foreach ($items as $item) {
            $this->model->newQuery()->create(array_merge(
                ['id_transaksi' => $transactionId],
                $item
            ));
        }
    }

    public function deleteForTransaction(int $transactionId): void
    {
        $this->model->newQuery()->where('id_transaksi', $transactionId)->delete();
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TransactionDetail extends Model
{
    protected $table = 'detail_transaksi';
    protected $primaryKey = 'id_detail';
    public $timestamps = false;

    protected $fillable = [
        'id_transaksi',
        'id_produk',
        'qty',
        'harga',
        'subtotal',
    ];

    protected $casts = [
        'qty' => 'integer',
        'harga' => 'decimal:2',
        'subtotal' => 'decimal:2',
    ];

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class, 'id_transaksi', 'id_transaksi');
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'id_produk', 'id_produk');
    }
}

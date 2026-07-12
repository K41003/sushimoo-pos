<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    protected $table = 'pembayaran';
    protected $primaryKey = 'id_pembayaran';
    public $timestamps = false;

    protected $fillable = [
        'id_transaksi',
        'id_metode',
        'total_bayar',
        'uang_diterima',
        'kembalian',
        'waktu_bayar',
        'status',
    ];

    protected $casts = [
        'total_bayar' => 'decimal:2',
        'uang_diterima' => 'decimal:2',
        'kembalian' => 'decimal:2',
        'waktu_bayar' => 'datetime',
    ];

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class, 'id_transaksi', 'id_transaksi');
    }

    public function method(): BelongsTo
    {
        return $this->belongsTo(PaymentMethod::class, 'id_metode', 'id_metode');
    }
}

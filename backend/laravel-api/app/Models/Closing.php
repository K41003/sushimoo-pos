<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Closing extends Model
{
    protected $table = 'closing_kasir';
    protected $primaryKey = 'id_closing';
    public $timestamps = false;

    protected $fillable = [
        'id_shift',
        'total_penjualan',
        'total_cash',
        'total_qris',
        'total_pengeluaran',
        'saldo_akhir',
        'waktu_closing',
        'status',
    ];

    protected $casts = [
        'total_penjualan' => 'decimal:2',
        'total_cash' => 'decimal:2',
        'total_qris' => 'decimal:2',
        'total_pengeluaran' => 'decimal:2',
        'saldo_akhir' => 'decimal:2',
        'waktu_closing' => 'datetime',
    ];

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class, 'id_shift', 'id_shift');
    }
}

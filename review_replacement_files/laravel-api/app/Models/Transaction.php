<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Transaction extends Model
{
    protected $table = 'transaksi';
    protected $primaryKey = 'id_transaksi';
    public $timestamps = true;

    protected $fillable = [
        'invoice_number',
        'id_shift',
        'id_user',
        'id_meja',
        'tanggal',
        'total',
        'status',
        'void_reason',
        'voided_by',
        'voided_at',
    ];

    protected $casts = [
        'total' => 'decimal:2',
        'tanggal' => 'datetime',
        'voided_at' => 'datetime',
    ];

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class, 'id_shift', 'id_shift');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function table(): BelongsTo
    {
        return $this->belongsTo(Table::class, 'id_meja', 'id_meja');
    }

    public function details(): HasMany
    {
        return $this->hasMany(TransactionDetail::class, 'id_transaksi', 'id_transaksi');
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class, 'id_transaksi', 'id_transaksi');
    }

    public function voidedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'voided_by', 'id_user');
    }
}

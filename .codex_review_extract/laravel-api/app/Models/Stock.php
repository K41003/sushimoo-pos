<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Stock extends Model
{
    protected $table = 'stok_bahan';
    protected $primaryKey = 'id_stok';
    public $timestamps = true;

    protected $fillable = [
        'id_bahan',
        'jumlah',
    ];

    protected $casts = [
        'jumlah' => 'decimal:2',
    ];

    public function ingredient(): BelongsTo
    {
        return $this->belongsTo(Ingredient::class, 'id_bahan', 'id_bahan');
    }
}

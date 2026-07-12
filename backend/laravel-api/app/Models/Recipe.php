<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Recipe extends Model
{
    protected $table = 'resep_produk';
    protected $primaryKey = 'id_resep';
    public $timestamps = true;

    protected $fillable = [
        'id_produk',
        'id_bahan',
        'qty',
    ];

    protected $casts = [
        'qty' => 'decimal:2',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class, 'id_produk', 'id_produk');
    }

    public function ingredient(): BelongsTo
    {
        return $this->belongsTo(Ingredient::class, 'id_bahan', 'id_bahan');
    }
}

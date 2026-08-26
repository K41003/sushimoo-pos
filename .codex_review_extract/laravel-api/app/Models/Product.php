<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Product extends Model
{
    protected $table = 'produk';
    protected $primaryKey = 'id_produk';
    public $timestamps = true;

    protected $fillable = [
        'id_kategori',
        'nama_produk',
        'harga',
        'gambar',
        'status',
    ];

    protected $casts = [
        'harga' => 'decimal:2',
        'status' => 'boolean',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'id_kategori', 'id_kategori');
    }

    public function details(): HasMany
    {
        return $this->hasMany(TransactionDetail::class, 'id_produk', 'id_produk');
    }

    public function recipes(): HasMany
    {
        return $this->hasMany(Recipe::class, 'id_produk', 'id_produk');
    }
}

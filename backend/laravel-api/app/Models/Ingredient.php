<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Ingredient extends Model
{
    protected $table = 'bahan_baku';
    protected $primaryKey = 'id_bahan';
    public $timestamps = true;

    protected $fillable = [
        'nama_bahan',
        'satuan',
        'minimal_stok',
    ];

    protected $casts = [
        'minimal_stok' => 'decimal:2',
    ];

    public function stocks(): HasMany
    {
        return $this->hasMany(Stock::class, 'id_bahan', 'id_bahan');
    }

    public function recipes(): HasMany
    {
        return $this->hasMany(Recipe::class, 'id_bahan', 'id_bahan');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Table extends Model
{
    protected $table = 'meja';
    protected $primaryKey = 'id_meja';
    public $timestamps = true;

    protected $fillable = [
        'nomor_meja',
        'kapasitas',
        'status',
    ];

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'id_meja', 'id_meja');
    }
}

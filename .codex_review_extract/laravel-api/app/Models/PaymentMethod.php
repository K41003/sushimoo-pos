<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PaymentMethod extends Model
{
    protected $table = 'metode_pembayaran';
    protected $primaryKey = 'id_metode';
    public $timestamps = false;

    protected $fillable = [
        'nama_metode',
        'status',
    ];

    protected $casts = [
        'status' => 'boolean',
    ];

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class, 'id_metode', 'id_metode');
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PettyCash extends Model
{
    protected $table = 'petty_cash';
    protected $primaryKey = 'id_pettycash';
    public $timestamps = true;
    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    protected $fillable = [
        'id_shift',
        'nominal',
        'keterangan',
    ];

    protected $casts = [
        'nominal' => 'decimal:2',
    ];

    public function shift(): BelongsTo
    {
        return $this->belongsTo(Shift::class, 'id_shift', 'id_shift');
    }
}

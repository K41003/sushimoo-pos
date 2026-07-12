<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Shift extends Model
{
    protected $table = 'shifts';
    protected $primaryKey = 'id_shift';
    public $timestamps = true;

    protected $fillable = [
        'id_user',
        'open_time',
        'close_time',
        'petty_cash',
        'status',
    ];

    protected $casts = [
        'petty_cash' => 'decimal:2',
        'open_time' => 'datetime',
        'close_time' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    public function pettyCashes(): HasMany
    {
        return $this->hasMany(PettyCash::class, 'id_shift', 'id_shift');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'id_shift', 'id_shift');
    }

    public function expenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'id_shift', 'id_shift');
    }

    public function closing(): HasOne
    {
        return $this->hasOne(Closing::class, 'id_shift', 'id_shift');
    }
}

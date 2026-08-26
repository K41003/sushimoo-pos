<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ActivityLog extends Model
{
    protected $table = 'activity_logs';
    protected $primaryKey = 'id_log';
    public $timestamps = false;
    const CREATED_AT = 'created_at';

    protected $fillable = [
        'id_user',
        'aktivitas',
        'ip_address',
        'created_at',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }
}

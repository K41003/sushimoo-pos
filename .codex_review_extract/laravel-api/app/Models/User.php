<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'users';
    protected $primaryKey = 'id_user';
    public $timestamps = true;

    protected $fillable = [
        'id_role',
        'nama',
        'username',
        'password',
        'status',
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'status' => 'boolean',
    ];

    public function role(): BelongsTo
    {
        return $this->belongsTo(Role::class, 'id_role', 'id_role');
    }

    public function shifts(): HasMany
    {
        return $this->hasMany(Shift::class, 'id_user', 'id_user');
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class, 'id_user', 'id_user');
    }

    public function activityLogs(): HasMany
    {
        return $this->hasMany(ActivityLog::class, 'id_user', 'id_user');
    }
}

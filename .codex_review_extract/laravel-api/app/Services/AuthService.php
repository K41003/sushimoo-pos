<?php

namespace App\Services;

use App\Repositories\Eloquent\ActivityLogRepository;
use App\Repositories\Eloquent\UserRepository;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function __construct(
        private UserRepository $users,
        private ActivityLogRepository $logs,
    ) {}

    public function attempt(string $username, string $password): ?\App\Models\User
    {
        $user = $this->users->findByUsername($username);

        if (! $user || ! Hash::check($password, $user->password)) {
            return null;
        }

        if (! $user->status) {
            return null;
        }

        return $user;
    }

    public function issueToken(\App\Models\User $user, string $device = 'pos'): string
    {
        return $user->createToken('pos-' . $device)->plainTextToken;
    }

    public function revokeCurrentToken(\App\Models\User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    public function revokeAllTokens(\App\Models\User $user): void
    {
        $user->tokens()->delete();
    }

    public function logActivity(int $userId, string $activity, ?string $ip = null): void
    {
        $this->logs->log($userId, $activity, $ip);
    }
}

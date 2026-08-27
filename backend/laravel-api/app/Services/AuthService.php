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

    /**
     * Verifies that `$username`/`$pin` belongs to an active Admin account.
     * Reuses the same password hash Admin already logs in with — there is
     * no separate "PIN" concept/column in the schema, so the Admin's
     * regular password doubles as the approval PIN in the UI. Does NOT
     * issue a token or touch the caller's session; this is purely a
     * yes/no check used to gate sensitive Kasir-initiated actions (e.g.
     * voiding an unpaid order) behind Admin approval.
     */
    public function verifyAdminPin(string $username, string $pin): bool
    {
        $user = $this->users->findByUsername($username);

        if (! $user || ! Hash::check($pin, $user->password)) {
            return false;
        }

        if (! $user->status) {
            return false;
        }

        $roleName = optional($user->role)->nama_role;

        return $roleName === 'Admin';
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

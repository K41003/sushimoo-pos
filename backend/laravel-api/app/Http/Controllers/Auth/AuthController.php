<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;

class AuthController extends Controller
{
    public function __construct(private AuthService $auth) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $user = $this->auth->attempt(
            $request->input('username'),
            $request->input('password')
        );

        if (! $user) {
            return $this->error('Invalid credentials or inactive account.', 401);
        }

        $token = $this->auth->issueToken($user);
        $this->auth->logActivity($user->id_user, 'Login', $request->ip());

        return $this->ok([
            'token' => $token,
            'user' => $user->load('role'),
        ], 'Login success');
    }

    public function me(): JsonResponse
    {
        $user = auth()->user();

        return $this->ok($user->load('role'), 'Authenticated');
    }

    public function logout(): JsonResponse
    {
        $user = auth()->user();
        $this->auth->revokeCurrentToken($user);
        $this->auth->logActivity($user->id_user, 'Logout', request()->ip());

        return $this->ok(null, 'Logout success');
    }
}

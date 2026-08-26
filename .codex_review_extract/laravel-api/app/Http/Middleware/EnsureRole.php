<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated.',
            ], 401);
        }

        if (empty($roles)) {
            return $next($request);
        }

        $roleName = optional($user->role)->nama_role;

        if (! in_array($roleName, $roles, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden. Required role: ' . implode(', ', $roles),
            ], 403);
        }

        return $next($request);
    }
}

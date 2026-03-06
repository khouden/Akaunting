<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class ApiAuthenticate
{
    /**
     * Handle an incoming request.
     *
     * Supports both Sanctum Bearer tokens and HTTP Basic Auth.
     * - If a Bearer token is present, authenticate via Sanctum.
     * - Otherwise, fall back to HTTP Basic Auth (backward compatible).
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        // If a Bearer token is present, use Sanctum
        if ($request->bearerToken()) {
            $user = Auth::guard('sanctum')->user();

            if (! $user) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthenticated. Invalid or expired token.',
                ], 401);
            }

            Auth::setUser($user);

            return $next($request);
        }

        // Fall back to HTTP Basic Auth (backward compatible)
        return Auth::onceBasic() ?: $next($request);
    }
}

<?php

namespace App\Http\Middleware;

use Closure;

class LogoutIfUserDisabled
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $user = user();

        if (!$user || $user->enabled) {
            return $next($request);
        }

        // For API requests, revoke token and return JSON
        if (request_is_api($request)) {
            if ($user->currentAccessToken()) {
                $user->currentAccessToken()->delete();
            }

            return response()->json([
                'success' => false,
                'message' => 'Your account has been disabled.',
            ], 403);
        }

        auth()->logout();

        return redirect()->route('login');
    }
}

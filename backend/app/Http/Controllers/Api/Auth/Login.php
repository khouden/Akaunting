<?php

namespace App\Http\Controllers\Api\Auth;

use App\Abstracts\Http\ApiController;
use App\Models\Auth\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class Login extends ApiController
{
    /**
     * Instantiate a new controller instance.
     */
    public function __construct()
    {
        // No permission middleware for auth endpoints
    }

    /**
     * Handle a login request and return a Sanctum token.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
            'device_name' => 'nullable|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => [trans('auth.failed')],
            ]);
        }

        if (! $user->enabled) {
            throw ValidationException::withMessages([
                'email' => [trans('auth.disabled')],
            ]);
        }

        $deviceName = $request->device_name ?? 'flutter-app';

        $token = $user->createToken($deviceName);

        return response()->json([
            'success' => true,
            'message' => trans('auth.login_success', [], 'en') ?: 'Login successful',
            'data' => [
                'token' => $token->plainTextToken,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'locale' => $user->locale,
                    'landing_page' => $user->landing_page,
                    'companies' => $user->companies->map(function ($company) {
                        return [
                            'id' => $company->id,
                            'name' => $company->name,
                            'domain' => $company->domain,
                        ];
                    }),
                    'roles' => $user->roles->pluck('name'),
                ],
            ],
        ], 200);
    }

    /**
     * Revoke the current token (logout).
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get the authenticated user's profile.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        $user->load('companies', 'roles');

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'locale' => $user->locale,
                'landing_page' => $user->landing_page,
                'enabled' => $user->enabled,
                'last_logged_in_at' => $user->last_logged_in_at,
                'created_at' => $user->created_at,
                'companies' => $user->companies->map(function ($company) {
                    return [
                        'id' => $company->id,
                        'name' => $company->name,
                        'email' => $company->email,
                        'domain' => $company->domain,
                        'currency' => $company->currency,
                        'enabled' => $company->enabled,
                    ];
                }),
                'roles' => $user->roles->pluck('name'),
            ],
        ], 200);
    }
}

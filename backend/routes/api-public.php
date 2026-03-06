<?php

use Illuminate\Support\Facades\Route;

/**
 * Public API routes - no authentication required.
 */
Route::group(['as' => 'api.', 'namespace' => 'Auth'], function () {
    Route::post('login', 'Login@login')->name('login');
});

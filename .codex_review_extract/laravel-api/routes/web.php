<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'success' => true,
        'message' => 'SUSHIMOO POS API',
        'data' => ['version' => '1.0.0'],
    ]);
});

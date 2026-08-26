<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Category\CategoryController;
use App\Http\Controllers\Closing\ClosingController;
use App\Http\Controllers\Dashboard\DashboardController;
use App\Http\Controllers\Expense\ExpenseController;
use App\Http\Controllers\Ingredient\IngredientController;
use App\Http\Controllers\Payment\PaymentController;
use App\Http\Controllers\Product\ProductController;
use App\Http\Controllers\Report\ReportController;
use App\Http\Controllers\Shift\ShiftController;
use App\Http\Controllers\Stock\StockController;
use App\Http\Controllers\Table\TableController;
use App\Http\Controllers\Transaction\TransactionController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| SUSHIMOO POS API Routes
| Controllers -> Services -> Repositories -> Models
|--------------------------------------------------------------------------
*/

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard/admin', [DashboardController::class, 'admin'])->middleware('role:Admin');
    Route::get('/dashboard/cashier', [DashboardController::class, 'cashier'])->middleware('role:Kasir');

    // Master: Category, Product, Ingredient, Stock, Table
    // Kasir can READ categories/products/tables (needed by the POS); only Admin can write.
    Route::apiResource('categories', CategoryController::class)
        ->middlewareFor(['index', 'show'], 'role:Admin,Kasir')
        ->middlewareFor(['store', 'update', 'destroy'], 'role:Admin');
    Route::apiResource('products', ProductController::class)
        ->middlewareFor(['index', 'show'], 'role:Admin,Kasir')
        ->middlewareFor(['store', 'update', 'destroy'], 'role:Admin');
    Route::apiResource('bahan-baku', IngredientController::class)->middleware('role:Admin');
    Route::apiResource('stok-bahan', StockController::class)->middleware('role:Admin');
    Route::apiResource('meja', TableController::class)
        ->middlewareFor(['index', 'show'], 'role:Admin,Kasir')
        ->middlewareFor(['store', 'update', 'destroy'], 'role:Admin');

    // Shift (Kasir)
    Route::get('/shifts/active', [ShiftController::class, 'active']);
    Route::post('/shifts/open', [ShiftController::class, 'open'])->middleware('role:Kasir');
    Route::post('/shifts/{id}/petty-cash', [ShiftController::class, 'pettyCash'])->middleware('role:Kasir');
    Route::post('/shifts/{id}/close', [ShiftController::class, 'close'])->middleware('role:Kasir');
    Route::get('/shifts/history', [ShiftController::class, 'history'])->middleware('role:Admin');

    // Transactions
    Route::get('/transaksi', [TransactionController::class, 'index'])->middleware('role:Admin');
    Route::post('/transaksi', [TransactionController::class, 'store'])->middleware('role:Kasir');
    Route::get('/transaksi/{id}', [TransactionController::class, 'show'])->middleware('role:Admin,Kasir');
    Route::put('/transaksi/{id}', [TransactionController::class, 'update'])->middleware('role:Kasir');
    Route::post('/transaksi/{id}/void', [TransactionController::class, 'void'])->middleware('role:Admin');

    // Payment
    Route::post('/transaksi/{id}/pembayaran', [PaymentController::class, 'pay'])->middleware('role:Kasir');

    // Expense (Kasir)
    Route::apiResource('pengeluaran', ExpenseController::class)->except(['create', 'edit'])->middleware('role:Kasir');

    // Closing
    Route::post('/shifts/{id}/closing', [ClosingController::class, 'store'])->middleware('role:Kasir');
    Route::get('/closing/history', [ClosingController::class, 'history'])->middleware('role:Admin');

    // Reports
    Route::get('/reports/daily', [ReportController::class, 'daily']);
    Route::get('/reports/monthly', [ReportController::class, 'monthly'])->middleware('role:Admin');
    Route::get('/reports/statistics', [ReportController::class, 'statistics'])->middleware('role:Admin');
    Route::get('/reports/last-7-days', [ReportController::class, 'last7Days']);
});

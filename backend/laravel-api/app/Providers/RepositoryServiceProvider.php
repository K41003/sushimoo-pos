<?php

namespace App\Providers;

use App\Repositories\Eloquent\ActivityLogRepository;
use App\Repositories\Eloquent\CategoryRepository;
use App\Repositories\Eloquent\ClosingRepository;
use App\Repositories\Eloquent\ExpenseRepository;
use App\Repositories\Eloquent\IngredientRepository;
use App\Repositories\Eloquent\PaymentMethodRepository;
use App\Repositories\Eloquent\PaymentRepository;
use App\Repositories\Eloquent\PettyCashRepository;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\RoleRepository;
use App\Repositories\Eloquent\ShiftRepository;
use App\Repositories\Eloquent\StockRepository;
use App\Repositories\Eloquent\TableRepository;
use App\Repositories\Eloquent\TransactionDetailRepository;
use App\Repositories\Eloquent\TransactionRepository;
use App\Repositories\Eloquent\UserRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $repositories = [
            UserRepository::class,
            RoleRepository::class,
            CategoryRepository::class,
            ProductRepository::class,
            IngredientRepository::class,
            StockRepository::class,
            TableRepository::class,
            ShiftRepository::class,
            PettyCashRepository::class,
            TransactionRepository::class,
            TransactionDetailRepository::class,
            PaymentMethodRepository::class,
            PaymentRepository::class,
            ExpenseRepository::class,
            ClosingRepository::class,
            ActivityLogRepository::class,
        ];

        foreach ($repositories as $repository) {
            $this->app->singleton($repository, fn () => new $repository());
        }
    }

    public function boot(): void
    {
        //
    }
}

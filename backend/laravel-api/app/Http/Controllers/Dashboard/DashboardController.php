<?php

namespace App\Http\Controllers\Dashboard;

use App\Http\Controllers\Controller;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __construct(private DashboardService $service) {}

    public function admin(): JsonResponse
    {
        return $this->ok($this->service->admin());
    }

    public function cashier(): JsonResponse
    {
        return $this->ok($this->service->cashier(auth()->id()));
    }
}

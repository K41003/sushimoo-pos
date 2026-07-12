<?php

namespace App\Http\Controllers\Report;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\JsonResponse;

class ReportController extends Controller
{
    public function __construct(private ReportService $service) {}

    public function daily(): JsonResponse
    {
        return $this->ok($this->service->daily(request()->query('date')));
    }

    public function monthly(): JsonResponse
    {
        $month = request()->query('month') ? (int) request()->query('month') : null;
        $year = request()->query('year') ? (int) request()->query('year') : null;

        return $this->ok($this->service->monthly($month, $year));
    }

    public function statistics(): JsonResponse
    {
        return $this->ok($this->service->statistics(
            request()->query('from'),
            request()->query('to')
        ));
    }

    public function last7Days(): JsonResponse
    {
        return $this->ok($this->service->last7Days());
    }
}

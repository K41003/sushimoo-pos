<?php

namespace App\Http\Controllers\Closing;

use App\Http\Controllers\Controller;
use App\Services\ClosingService;
use App\Services\ShiftService;
use Illuminate\Http\JsonResponse;

class ClosingController extends Controller
{
    public function __construct(
        private ClosingService $closing,
        private ShiftService $shifts,
    ) {}

    public function store(int $shiftId): JsonResponse
    {
        $shift = \App\Models\Shift::findOrFail($shiftId);

        try {
            $closing = $this->shifts->close($shift, request()->ip());
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->created($closing->load('shift'), 'Closing recorded');
    }

    public function history(): JsonResponse
    {
        return $this->paginated($this->closing->history((int) request()->query('perPage', 15)));
    }
}

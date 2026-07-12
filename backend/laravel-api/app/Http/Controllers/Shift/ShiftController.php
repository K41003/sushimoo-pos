<?php

namespace App\Http\Controllers\Shift;

use App\Http\Controllers\Controller;
use App\Http\Requests\Shift\OpenShiftRequest;
use App\Http\Requests\Shift\PettyCashRequest;
use App\Services\ShiftService;
use Illuminate\Http\JsonResponse;

class ShiftController extends Controller
{
    public function __construct(private ShiftService $service) {}

    public function active(): JsonResponse
    {
        $shift = $this->service->activeForUser(auth()->id());

        return $this->ok($shift, $shift ? 'Active shift found' : 'No active shift');
    }

    public function open(OpenShiftRequest $request): JsonResponse
    {
        try {
            $shift = $this->service->open(
                auth()->id(),
                (float) $request->input('petty_cash'),
                $request->ip()
            );
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->created($shift, 'Shift opened');
    }

    public function pettyCash(int $id, PettyCashRequest $request): JsonResponse
    {
        $petty = $this->service->addPettyCash(
            $id,
            (float) $request->input('nominal'),
            $request->input('keterangan')
        );

        return $this->created($petty, 'Petty cash recorded');
    }

    public function close(int $id): JsonResponse
    {
        $shift = \App\Models\Shift::findOrFail($id);

        try {
            $closing = $this->service->close($shift, request()->ip());
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->created($closing->load('shift'), 'Shift closed');
    }

    public function history(): JsonResponse
    {
        return $this->paginated($this->service->history((int) request()->query('perPage', 15)));
    }
}

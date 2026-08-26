<?php

namespace App\Services;

use App\Models\Shift;
use App\Repositories\Eloquent\PettyCashRepository;
use App\Repositories\Eloquent\ShiftRepository;
use Illuminate\Support\Facades\DB;

class ShiftService
{
    public function __construct(
        private ShiftRepository $shifts,
        private PettyCashRepository $pettyCashes,
        private ClosingService $closing,
        private \App\Repositories\Eloquent\ActivityLogRepository $logs,
    ) {}

    public function activeForUser(int $userId): ?Shift
    {
        return $this->shifts->activeForUser($userId);
    }

    public function open(int $userId, float $pettyCash, ?string $ip = null): Shift
    {
        if ($this->shifts->activeForUser($userId)) {
            throw new \RuntimeException('Shift already open for this user.');
        }

        $shift = $this->shifts->create([
            'id_user' => $userId,
            'open_time' => now(),
            'petty_cash' => $pettyCash,
            'status' => 'open',
        ]);

        $this->logs->log($userId, 'Open shift', $ip);

        return $shift;
    }

    public function addPettyCash(int $shiftId, float $nominal, ?string $keterangan): \App\Models\PettyCash
    {
        return $this->pettyCashes->create([
            'id_shift' => $shiftId,
            'nominal' => $nominal,
            'keterangan' => $keterangan,
        ]);
    }

    public function close(Shift $shift, ?string $ip = null): \App\Models\Closing
    {
        if ($shift->status === 'closed') {
            throw new \RuntimeException('Shift already closed.');
        }

        return DB::transaction(function () use ($shift, $ip) {
            $shift->update([
                'close_time' => now(),
                'status' => 'closed',
            ]);

            $this->logs->log($shift->id_user, 'Close shift', $ip);

            return $this->closing->computeAndStore($shift);
        });
    }

    public function history(int $perPage = 15)
    {
        return $this->shifts->history($perPage);
    }
}

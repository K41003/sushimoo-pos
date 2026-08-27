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

    /**
     * Closes the shift itself (clocks the cashier out). This does NOT
     * generate the end-of-day Closing report — that is a separate,
     * explicit step handled by `closeAndGenerateReport()` /
     * `ClosingController::store` (`POST /shifts/{id}/closing`), which the
     * Kasir triggers from the dedicated "Closing" page.
     *
     * Keeping these two actions separate avoids the previous bug where
     * both `/shifts/{id}/close` and `/shifts/{id}/closing` ended up
     * calling the same close+compute logic: the first call would close
     * the shift and silently generate the report, and the second call
     * (from the Closing page's "Closing Kasir" button) would then fail
     * with "Shift already closed" — leaving the Kasir with no active
     * shift to close and no way to see the report that was already
     * created, since `/closing/history` was Admin-only.
     */
    public function close(Shift $shift, ?string $ip = null): Shift
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

            return $shift->fresh();
        });
    }

    /**
     * The actual end-of-day "Closing Kasir" action: closes the shift if
     * it's still open (so the Kasir doesn't have to remember to close it
     * separately first) and generates the Closing report.
     *
     * Idempotent: if a Closing report already exists for this shift
     * (e.g. the shift was already closed and reported earlier), the
     * existing report is returned instead of computing a duplicate one.
     */
    public function closeAndGenerateReport(Shift $shift, ?string $ip = null): \App\Models\Closing
    {
        return DB::transaction(function () use ($shift, $ip) {
            $existing = $shift->closing()->first();
            if ($existing) {
                return $existing;
            }

            if ($shift->status !== 'closed') {
                $shift->update([
                    'close_time' => now(),
                    'status' => 'closed',
                ]);

                $this->logs->log($shift->id_user, 'Close shift', $ip);
            }

            return $this->closing->computeAndStore($shift->fresh());
        });
    }

    public function history(int $perPage = 15)
    {
        return $this->shifts->history($perPage);
    }
}

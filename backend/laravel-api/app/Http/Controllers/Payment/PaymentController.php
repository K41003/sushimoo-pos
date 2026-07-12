<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Http\Requests\Payment\PaymentRequest;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;

class PaymentController extends Controller
{
    public function __construct(private PaymentService $service) {}

    public function pay(int $transactionId, PaymentRequest $request): JsonResponse
    {
        try {
            $payment = $this->service->pay(
                $transactionId,
                (int) $request->input('id_metode'),
                $request->filled('uang_diterima') ? (float) $request->input('uang_diterima') : null
            );
        } catch (\RuntimeException $e) {
            return $this->error($e->getMessage(), 422);
        }

        return $this->created($payment, 'Payment success');
    }
}

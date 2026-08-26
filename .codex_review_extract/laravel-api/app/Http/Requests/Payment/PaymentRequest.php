<?php

namespace App\Http\Requests\Payment;

use Illuminate\Foundation\Http\FormRequest;

class PaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_metode' => ['required', 'integer', 'exists:metode_pembayaran,id_metode'],
            'uang_diterima' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}

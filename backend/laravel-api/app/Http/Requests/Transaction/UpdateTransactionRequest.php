<?php

namespace App\Http\Requests\Transaction;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.id_produk' => ['required', 'integer', 'exists:produk,id_produk'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
            'items.*.catatan' => ['nullable', 'string'],
        ];
    }
}

<?php

namespace App\Http\Requests\Stock;

use Illuminate\Foundation\Http\FormRequest;

class StockRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('id');

        return [
            'id_bahan' => ['required_without:id', 'integer', 'exists:bahan_baku,id_bahan'],
            'jumlah' => ['required', 'numeric'],
        ];
    }
}

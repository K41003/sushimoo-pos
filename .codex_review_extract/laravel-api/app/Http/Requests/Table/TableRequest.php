<?php

namespace App\Http\Requests\Table;

use Illuminate\Foundation\Http\FormRequest;

class TableRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nomor_meja' => ['required', 'string', 'max:20'],
            'kapasitas' => ['nullable', 'integer', 'min:1'],
            'status' => ['nullable', 'in:available,occupied,reserved,cleaning'],
        ];
    }
}

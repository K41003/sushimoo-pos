<?php

namespace App\Http\Requests\Ingredient;

use Illuminate\Foundation\Http\FormRequest;

class IngredientRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'nama_bahan' => ['required', 'string', 'max:100'],
            'satuan' => ['required', 'string', 'max:30'],
            'minimal_stok' => ['nullable', 'numeric', 'min:0'],
        ];
    }
}

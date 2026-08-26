<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class ProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'id_kategori' => ['required', 'integer', 'exists:kategori_produk,id_kategori'],
            'nama_produk' => ['required', 'string', 'max:100'],
            'harga' => ['required', 'numeric', 'min:0'],
            'gambar' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'boolean'],
            'recipes' => ['nullable', 'array'],
            'recipes.*.id_bahan' => ['required_with:recipes', 'integer', 'exists:bahan_baku,id_bahan'],
            'recipes.*.qty' => ['required_with:recipes', 'numeric', 'min:0'],
        ];
    }
}

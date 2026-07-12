<?php

namespace App\Http\Controllers\Product;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\ProductRequest;
use App\Services\ProductService;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function __construct(private ProductService $service) {}

    public function index(): JsonResponse
    {
        $q = request()->query('q');
        $categoryId = request()->query('id_kategori') ? (int) request()->query('id_kategori') : null;
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($q, $categoryId, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function store(ProductRequest $request): JsonResponse
    {
        return $this->created($this->service->create($request->validated()), 'Product created');
    }

    public function update(int $id, ProductRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Product updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Product deleted');
    }
}

<?php

namespace App\Http\Controllers\Category;

use App\Http\Controllers\Controller;
use App\Http\Requests\Category\CategoryRequest;
use App\Services\CategoryService;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function __construct(private CategoryService $service) {}

    public function index(): JsonResponse
    {
        $q = request()->query('q', '');
        $perPage = (int) request()->query('perPage', 15);

        return $this->paginated($this->service->list($q, $perPage));
    }

    public function show(int $id): JsonResponse
    {
        return $this->ok($this->service->find($id));
    }

    public function store(CategoryRequest $request): JsonResponse
    {
        return $this->created($this->service->create($request->validated()), 'Category created');
    }

    public function update(int $id, CategoryRequest $request): JsonResponse
    {
        return $this->ok($this->service->update($id, $request->validated()), 'Category updated');
    }

    public function destroy(int $id): JsonResponse
    {
        $this->service->delete($id);

        return $this->ok(null, 'Category deleted');
    }
}

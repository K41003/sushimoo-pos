<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    protected User $admin;

    protected function setUp(): void
    {
        parent::setUp();
        Role::insert([
            ['nama_role' => 'Admin', 'deskripsi' => 'Administrator', 'created_at' => now(), 'updated_at' => now()],
            ['nama_role' => 'Kasir', 'deskripsi' => 'Kasir', 'created_at' => now(), 'updated_at' => now()],
        ]);
        $this->admin = User::create([
            'id_role' => 1,
            'nama' => 'Admin',
            'username' => 'admin',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);
    }

    public function test_admin_can_create_product(): void
    {
        $category = Category::create(['nama_kategori' => 'Sushi', 'status' => 1]);

        $response = $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/products', [
                'id_kategori' => $category->id_kategori,
                'nama_produk' => 'Salmon Roll',
                'harga' => 45000,
                'status' => 1,
            ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.nama_produk', 'Salmon Roll');
    }

    public function test_product_validation_fails_without_category(): void
    {
        $this->actingAs($this->admin, 'sanctum')
            ->postJson('/api/products', [
                'nama_produk' => 'X',
                'harga' => 1000,
            ])
            ->assertStatus(422)
            ->assertJsonPath('success', false);
    }

    public function test_admin_can_list_products(): void
    {
        Category::create(['nama_kategori' => 'Sushi', 'status' => 1]);
        $this->actingAs($this->admin, 'sanctum')
            ->getJson('/api/products')
            ->assertOk()
            ->assertJsonStructure(['data' => ['items', 'meta']]);
    }

    public function test_kasir_cannot_manage_products(): void
    {
        $kasir = User::create([
            'id_role' => 2,
            'nama' => 'Kasir',
            'username' => 'kasir',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);

        $this->actingAs($kasir, 'sanctum')
            ->postJson('/api/products', [
                'id_kategori' => 1,
                'nama_produk' => 'X',
                'harga' => 1000,
            ])
            ->assertForbidden();
    }
}

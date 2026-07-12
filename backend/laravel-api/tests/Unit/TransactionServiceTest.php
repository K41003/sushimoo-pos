<?php

namespace Tests\Unit;

use App\Models\Product;
use App\Models\Shift;
use App\Models\Table;
use App\Models\User;
use App\Models\Role;
use App\Models\Category;
use App\Repositories\Eloquent\ProductRepository;
use App\Repositories\Eloquent\TableRepository;
use App\Repositories\Eloquent\TransactionDetailRepository;
use App\Repositories\Eloquent\TransactionRepository;
use App\Services\TransactionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransactionServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_create_computes_total_and_occupies_table(): void
    {
        Role::insert([
            ['nama_role' => 'Admin', 'deskripsi' => 'Administrator', 'created_at' => now(), 'updated_at' => now()],
        ]);
        $user = User::factory()->create();
        Shift::create(['id_user' => $user->id_user, 'open_time' => now(), 'petty_cash' => 0, 'status' => 'open']);
        $table = Table::create(['nomor_meja' => 'M01', 'kapasitas' => 4, 'status' => 'available']);
        $category = Category::create(['nama_kategori' => 'Sushi', 'status' => 1]);
        $product = Product::create(['id_kategori' => $category->id_kategori, 'nama_produk' => 'A', 'harga' => 10000, 'status' => 1]);

        $service = new TransactionService(
            new TransactionRepository(),
            new TransactionDetailRepository(),
            new TableRepository()
        );

        $transaction = $service->create([
            'id_meja' => $table->id_meja,
            'items' => [['id_produk' => $product->id_produk, 'qty' => 3, 'harga' => 10000]],
        ], $user->id_user);

        $this->assertEquals(30000, $transaction->total);
        $this->assertEquals('occupied', $table->fresh()->status);
        $this->assertCount(1, $transaction->details);
    }
}

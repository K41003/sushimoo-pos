<?php

namespace Tests\Feature;

use App\Models\PaymentMethod;
use App\Models\Role;
use App\Models\Table;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class CashierFlowTest extends TestCase
{
    use RefreshDatabase;

    protected User $kasir;

    protected function setUp(): void
    {
        parent::setUp();
        Role::insert([
            ['nama_role' => 'Admin', 'deskripsi' => 'Administrator', 'created_at' => now(), 'updated_at' => now()],
            ['nama_role' => 'Kasir', 'deskripsi' => 'Kasir', 'created_at' => now(), 'updated_at' => now()],
        ]);
        PaymentMethod::insert([
            ['nama_metode' => 'Cash', 'status' => 1],
            ['nama_metode' => 'QRIS', 'status' => 1],
            ['nama_metode' => 'Debit', 'status' => 1],
        ]);
        Table::create(['nomor_meja' => 'M01', 'kapasitas' => 4, 'status' => 'available']);
        $this->kasir = User::create([
            'id_role' => 2,
            'nama' => 'Kasir',
            'username' => 'kasir',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);
    }

    public function test_cashier_full_flow(): void
    {
        $this->actingAs($this->kasir, 'sanctum');

        // Open shift
        $open = $this->postJson('/api/shifts/open', ['petty_cash' => 100000]);
        $open->assertCreated();
        $shiftId = $open->json('data.id_shift');

        // Create a product on-the-fly via direct insert for the order
        $productId = \DB::table('produk')->insertGetId([
            'id_kategori' => \DB::table('kategori_produk')->insertGetId([
                'nama_kategori' => 'Sushi', 'deskripsi' => null, 'status' => 1,
                'created_at' => now(), 'updated_at' => now(),
            ]),
            'nama_produk' => 'Salmon Roll', 'harga' => 45000, 'gambar' => null, 'status' => 1,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        // Create transaction
        $trx = $this->postJson('/api/transaksi', [
            'id_meja' => 1,
            'items' => [['id_produk' => $productId, 'qty' => 2, 'harga' => 45000]],
        ]);
        $trx->assertCreated();
        $trxId = $trx->json('data.id_transaksi');
        $this->assertEquals(90000, $trx->json('data.total'));

        // Pay
        $pay = $this->postJson('/api/transaksi/' . $trxId . '/pembayaran', [
            'id_metode' => 1,
            'uang_diterima' => 100000,
        ]);
        $pay->assertCreated();
        $this->assertEquals(10000, $pay->json('data.kembalian'));

        // Expense
        $this->postJson('/api/pengeluaran', [
            'kategori' => 'Listrik',
            'nominal' => 20000,
        ])->assertCreated();

        // Closing
        $closing = $this->postJson('/api/shifts/' . $shiftId . '/closing');
        $closing->assertCreated();
        $this->assertEquals(90000, $closing->json('data.total_penjualan'));
        $this->assertEquals(20000, $closing->json('data.total_pengeluaran'));
    }

    public function test_cash_payment_rejects_insufficient_received_amount(): void
    {
        $this->actingAs($this->kasir, 'sanctum');

        $this->postJson('/api/shifts/open', ['petty_cash' => 100000])->assertCreated();

        $productId = \DB::table('produk')->insertGetId([
            'id_kategori' => \DB::table('kategori_produk')->insertGetId([
                'nama_kategori' => 'Sushi', 'deskripsi' => null, 'status' => 1,
                'created_at' => now(), 'updated_at' => now(),
            ]),
            'nama_produk' => 'Salmon Roll', 'harga' => 45000, 'gambar' => null, 'status' => 1,
            'created_at' => now(), 'updated_at' => now(),
        ]);

        $trx = $this->postJson('/api/transaksi', [
            'id_meja' => 1,
            'items' => [['id_produk' => $productId, 'qty' => 2]],
        ]);
        $trx->assertCreated();

        $this->postJson('/api/transaksi/' . $trx->json('data.id_transaksi') . '/pembayaran', [
            'id_metode' => 1,
            'uang_diterima' => 1000,
        ])->assertStatus(422);
    }
}

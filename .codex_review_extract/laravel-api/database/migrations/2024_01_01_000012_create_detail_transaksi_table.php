<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('detail_transaksi', function (Blueprint $table) {
            $table->bigIncrements('id_detail');
            $table->unsignedBigInteger('id_transaksi');
            $table->unsignedBigInteger('id_produk');
            $table->integer('qty');
            $table->decimal('harga', 15, 2);
            $table->decimal('subtotal', 15, 2);

            $table->foreign('id_transaksi', 'fk_detail_transaksi')
                ->references('id_transaksi')->on('transaksi')
                ->onDelete('cascade');
            $table->foreign('id_produk', 'fk_detail_produk')
                ->references('id_produk')->on('produk');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('detail_transaksi');
    }
};

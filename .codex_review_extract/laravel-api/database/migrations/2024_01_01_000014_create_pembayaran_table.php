<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pembayaran', function (Blueprint $table) {
            $table->bigIncrements('id_pembayaran');
            $table->unsignedBigInteger('id_transaksi');
            $table->unsignedBigInteger('id_metode');
            $table->decimal('total_bayar', 15, 2);
            $table->decimal('uang_diterima', 15, 2)->default(0);
            $table->decimal('kembalian', 15, 2)->default(0);
            $table->dateTime('waktu_bayar')->nullable();
            $table->enum('status', ['success', 'failed'])->default('success');

            $table->foreign('id_transaksi', 'fk_pembayaran_transaksi')
                ->references('id_transaksi')->on('transaksi');
            $table->foreign('id_metode', 'fk_pembayaran_metode')
                ->references('id_metode')->on('metode_pembayaran');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pembayaran');
    }
};

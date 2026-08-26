<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('closing_kasir', function (Blueprint $table) {
            $table->bigIncrements('id_closing');
            $table->unsignedBigInteger('id_shift');
            $table->decimal('total_penjualan', 15, 2)->default(0);
            $table->decimal('total_cash', 15, 2)->default(0);
            $table->decimal('total_qris', 15, 2)->default(0);
            $table->decimal('total_pengeluaran', 15, 2)->default(0);
            $table->decimal('saldo_akhir', 15, 2)->default(0);
            $table->dateTime('waktu_closing')->nullable();
            $table->enum('status', ['success', 'cancelled'])->default('success');

            $table->foreign('id_shift', 'fk_closing_shift')
                ->references('id_shift')->on('shifts');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('closing_kasir');
    }
};

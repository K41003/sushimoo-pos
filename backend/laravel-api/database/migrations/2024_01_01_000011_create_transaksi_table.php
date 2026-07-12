<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaksi', function (Blueprint $table) {
            $table->bigIncrements('id_transaksi');
            $table->string('invoice_number', 50)->unique();
            $table->unsignedBigInteger('id_shift');
            $table->unsignedBigInteger('id_user');
            $table->unsignedBigInteger('id_meja');
            $table->dateTime('tanggal');
            $table->decimal('total', 15, 2)->default(0);
            $table->enum('status', ['pending', 'paid', 'cancelled'])->default('pending');
            $table->timestamps();

            $table->foreign('id_shift', 'fk_transaksi_shift')
                ->references('id_shift')->on('shifts');
            $table->foreign('id_user', 'fk_transaksi_user')
                ->references('id_user')->on('users');
            $table->foreign('id_meja', 'fk_transaksi_meja')
                ->references('id_meja')->on('meja');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaksi');
    }
};

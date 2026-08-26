<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengeluaran', function (Blueprint $table) {
            $table->bigIncrements('id_pengeluaran');
            $table->unsignedBigInteger('id_shift');
            $table->string('kategori', 100);
            $table->decimal('nominal', 15, 2);
            $table->text('keterangan')->nullable();
            $table->dateTime('tanggal');

            $table->foreign('id_shift', 'fk_pengeluaran_shift')
                ->references('id_shift')->on('shifts');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengeluaran');
    }
};

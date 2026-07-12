<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('stok_bahan', function (Blueprint $table) {
            $table->bigIncrements('id_stok');
            $table->unsignedBigInteger('id_bahan');
            $table->decimal('jumlah', 15, 2)->default(0);
            $table->timestamps();

            $table->foreign('id_bahan', 'fk_stok_bahan')
                ->references('id_bahan')->on('bahan_baku')
                ->onUpdate('cascade')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('stok_bahan');
    }
};

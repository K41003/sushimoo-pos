<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('resep_produk', function (Blueprint $table) {
            $table->bigIncrements('id_resep');
            $table->unsignedBigInteger('id_produk');
            $table->unsignedBigInteger('id_bahan');
            $table->decimal('qty', 15, 2);
            $table->timestamps();

            $table->foreign('id_produk', 'fk_resep_produk')
                ->references('id_produk')->on('produk')
                ->onUpdate('cascade')->onDelete('cascade');
            $table->foreign('id_bahan', 'fk_resep_bahan')
                ->references('id_bahan')->on('bahan_baku')
                ->onUpdate('cascade')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('resep_produk');
    }
};

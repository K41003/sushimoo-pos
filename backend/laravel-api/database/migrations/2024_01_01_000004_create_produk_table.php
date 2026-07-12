<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('produk', function (Blueprint $table) {
            $table->bigIncrements('id_produk');
            $table->unsignedBigInteger('id_kategori');
            $table->string('nama_produk', 100);
            $table->decimal('harga', 15, 2);
            $table->string('gambar', 255)->nullable();
            $table->boolean('status')->default(1);
            $table->timestamps();

            $table->foreign('id_kategori', 'fk_produk_kategori')
                ->references('id_kategori')->on('kategori_produk')
                ->onUpdate('cascade')->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('produk');
    }
};

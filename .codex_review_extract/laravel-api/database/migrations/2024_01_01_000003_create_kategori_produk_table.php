<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('kategori_produk', function (Blueprint $table) {
            $table->bigIncrements('id_kategori');
            $table->string('nama_kategori', 100);
            $table->text('deskripsi')->nullable();
            $table->boolean('status')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('kategori_produk');
    }
};

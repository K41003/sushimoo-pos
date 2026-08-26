<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('metode_pembayaran', function (Blueprint $table) {
            $table->bigIncrements('id_metode');
            $table->string('nama_metode', 50);
            $table->boolean('status')->default(1);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('metode_pembayaran');
    }
};

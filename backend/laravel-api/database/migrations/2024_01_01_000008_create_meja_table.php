<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('meja', function (Blueprint $table) {
            $table->bigIncrements('id_meja');
            $table->string('nomor_meja', 20);
            $table->integer('kapasitas')->default(1);
            $table->enum('status', ['available', 'occupied', 'reserved', 'cleaning'])
                ->default('available');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('meja');
    }
};

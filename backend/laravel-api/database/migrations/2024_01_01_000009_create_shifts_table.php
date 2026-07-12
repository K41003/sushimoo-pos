<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shifts', function (Blueprint $table) {
            $table->bigIncrements('id_shift');
            $table->unsignedBigInteger('id_user');
            $table->dateTime('open_time')->nullable();
            $table->dateTime('close_time')->nullable();
            $table->decimal('petty_cash', 15, 2)->default(0);
            $table->enum('status', ['open', 'closed'])->default('open');
            $table->timestamps();

            $table->foreign('id_user', 'fk_shift_user')
                ->references('id_user')->on('users')
                ->onUpdate('cascade')->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shifts');
    }
};

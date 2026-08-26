<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->bigIncrements('id_log');
            $table->unsignedBigInteger('id_user')->nullable();
            $table->text('aktivitas');
            $table->string('ip_address', 50)->nullable();
            $table->dateTime('created_at')->nullable();

            $table->foreign('id_user', 'fk_log_user')
                ->references('id_user')->on('users')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};

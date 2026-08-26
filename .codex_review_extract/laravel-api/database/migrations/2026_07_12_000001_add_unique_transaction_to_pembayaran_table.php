<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pembayaran', function (Blueprint $table) {
            $table->unique('id_transaksi', 'pembayaran_id_transaksi_unique');
        });
    }

    public function down(): void
    {
        Schema::table('pembayaran', function (Blueprint $table) {
            $table->dropUnique('pembayaran_id_transaksi_unique');
        });
    }
};

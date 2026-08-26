<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('transaksi', function (Blueprint $table) {
            $table->string('void_reason', 255)->nullable()->after('status');
            $table->unsignedBigInteger('voided_by')->nullable()->after('void_reason');
            $table->dateTime('voided_at')->nullable()->after('voided_by');

            $table->foreign('voided_by', 'fk_transaksi_voided_by')
                ->references('id_user')->on('users')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('transaksi', function (Blueprint $table) {
            $table->dropForeign('fk_transaksi_voided_by');
            $table->dropColumn(['void_reason', 'voided_by', 'voided_at']);
        });
    }
};

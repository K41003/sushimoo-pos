<?php

namespace Database\Seeders;

use App\Models\Table;
use Illuminate\Database\Seeder;

class TableSeeder extends Seeder
{
    public function run(): void
    {
        $tables = [
            ['nomor_meja' => 'M01', 'kapasitas' => 4],
            ['nomor_meja' => 'M02', 'kapasitas' => 4],
            ['nomor_meja' => 'M03', 'kapasitas' => 6],
            ['nomor_meja' => 'M04', 'kapasitas' => 2],
            ['nomor_meja' => 'M05', 'kapasitas' => 2],
        ];

        foreach ($tables as $t) {
            Table::updateOrCreate(
                ['nomor_meja' => $t['nomor_meja']],
                array_merge($t, ['status' => 'available', 'created_at' => now(), 'updated_at' => now()])
            );
        }
    }
}

<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        Role::updateOrCreate(
            ['nama_role' => 'Admin'],
            ['nama_role' => 'Admin', 'deskripsi' => 'Administrator', 'created_at' => now(), 'updated_at' => now()]
        );
        Role::updateOrCreate(
            ['nama_role' => 'Kasir'],
            ['nama_role' => 'Kasir', 'deskripsi' => 'Kasir', 'created_at' => now(), 'updated_at' => now()]
        );
    }
}

<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $adminRole = \App\Models\Role::where('nama_role', 'Admin')->first();
        $kasirRole = \App\Models\Role::where('nama_role', 'Kasir')->first();

        User::updateOrCreate(
            ['username' => 'admin'],
            [
                'id_role' => $adminRole?->id_role ?? 1,
                'nama' => 'Administrator',
                'password' => Hash::make('admin123'),
                'status' => 1,
            ]
        );

        User::updateOrCreate(
            ['username' => 'kasir'],
            [
                'id_role' => $kasirRole?->id_role ?? 2,
                'nama' => 'Kasir Satu',
                'password' => Hash::make('kasir123'),
                'status' => 1,
            ]
        );
    }
}

<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::insert([
            ['nama_role' => 'Admin', 'deskripsi' => 'Administrator', 'created_at' => now(), 'updated_at' => now()],
            ['nama_role' => 'Kasir', 'deskripsi' => 'Kasir', 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    public function test_login_returns_token_for_valid_credentials(): void
    {
        User::create([
            'id_role' => 1,
            'nama' => 'Admin',
            'username' => 'admin',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);

        $response = $this->postJson('/api/login', [
            'username' => 'admin',
            'password' => 'secret123',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['token', 'user']]);
    }

    public function test_login_fails_for_invalid_credentials(): void
    {
        User::create([
            'id_role' => 1,
            'nama' => 'Admin',
            'username' => 'admin',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);

        $this->postJson('/api/login', [
            'username' => 'admin',
            'password' => 'wrong',
        ])->assertStatus(401)
            ->assertJsonPath('success', false);
    }

    public function test_me_requires_authentication(): void
    {
        $this->getJson('/api/me')->assertStatus(401);
    }

    public function test_logout_revokes_token(): void
    {
        $user = User::create([
            'id_role' => 1,
            'nama' => 'Admin',
            'username' => 'admin',
            'password' => Hash::make('secret123'),
            'status' => 1,
        ]);
        $token = $user->createToken('pos')->plainTextToken;

        $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/logout')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }
}

<?php

return [

    'api' => [
        'middleware' => [
            'verify_csrf_token' => false,
            'throttle' => false,
        ],

        'prefix' => 'api',
        'domain' => null,

        'expiration' => null,
        'middleware' => ['api'],
    ],

    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost')),
    'guard' => ['web'],
    'middleware' => ['web'],

];

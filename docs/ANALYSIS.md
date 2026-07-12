# SUSHIMOO POS — Architecture Analysis

Synthesis of `Design.md`, `Project-Structure.md`, and `schema.sql`.

## 1. Sources of Truth
- **Design.md** → Color systems (Dark "Zen Precision" + Light "Sushi Red"), typography (Inter), spacing (8px baseline), radius, component specs, responsive rules (Tablet Landscape 12-col nav-rail + menu + cart; Tablet Portrait 8-col; Mobile 4-col), touch targets ≥ 48px.
- **Project-Structure.md** → Folder trees for `backend/laravel-api`, `mobile/flutter-pos`, `database`, `docs`; Laravel model list; Flutter module list; GetX module layout; dependencies; roles & permissions; sprint roadmap.
- **schema.sql** → 18 tables, custom BIGINT primary keys (`id_role`, `id_user`, …), enums, foreign keys, seed data (roles, payment methods, tables).

## 2. Key Architectural Decisions
- **Laravel**: `Controllers → Services → Repositories → Models`. Controllers never touch models directly. Business logic in Services, DB access in Repositories (Repository Pattern + Service Layer + DI via Laravel container).
- **Auth**: Laravel Sanctum (token). Endpoints `/login`, `/logout`, `/me`. Roles: `Admin`, `Kasir` (from `roles` table). Middleware `auth:sanctum` + `role:` middleware.
- **Custom PKs**: Every model maps `protected $primaryKey` + `protected $table` to the exact schema names. `incrementing = true`, `$keyType = 'int'`.
- **Response envelope**: `{success:bool, message:string, data:?}` for success; `{success:false, message:string}` for errors. Centralized via `ApiResponse` trait.
- **Flutter**: GetX. `lib/{app,data,modules,shared}`. Each module = `bindings/ controllers/ views/ widgets/`. One `ApiClient` (Dio) singleton. `ApiResponse` model mirrors backend envelope.
- **Theming**: `theme.dart` exports `lightTheme` (Sushi Red / Sumie / Rice White) and `darkTheme` (Zen Crimson / Ink). Both use Inter, 8px spacing rhythm, rounded tokens.
- **DB workflow**: `database/schema.sql` is the canonical DDL. Mirrored 1:1 by Laravel migrations so `php artisan migrate` reproduces it. `seed.sql` seeds roles, payment methods, tables, and an admin user.

## 3. Cross-Reference Validation
| Requirement | Source | Resolution |
|---|---|---|
| 18 models | Project-Structure | Exact match to schema tables (+ ActivityLog) |
| Crimson/Ink dark + Sushi Red light | Design.md | Both palettes encoded in `theme.dart` |
| 48px touch targets | Design.md | `kTouchTarget` constant + min sizes |
| Sanctum + roles | General/Security | `auth:sanctum` + `role` middleware |
| POS left categories/products, right cart | POS Requirements | `pos` module layout |
| Print kitchen ticket / receipt / closing | Printer | `PrinterService` in `app/services` + Flutter `printer/` |
| All listed endpoints | API Development | See API_CONTRACT + ROUTE_MAPPING |

> No architecture changes made without this documented plan.

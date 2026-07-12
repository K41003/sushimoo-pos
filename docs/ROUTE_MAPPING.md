# Route Mapping — Controllers → Services → Repositories

`routes/api.php` prefixes `v1`. All routes inside `auth:sanctum` group except `POST /login`.

| Route | Method | Controller@action | Service | Repository |
|---|---|---|---|---|
| /login | POST | AuthController@login | AuthService | UserRepository |
| /logout | POST | AuthController@logout | AuthService | UserRepository |
| /me | GET | AuthController@me | AuthService | UserRepository |
| /dashboard/admin | GET | DashboardController@admin | DashboardService | Transaction, Product, Expense |
| /dashboard/cashier | GET | DashboardController@cashier | DashboardService | Shift, Transaction |
| /categories (CRUD) | GET/POST/GET/PUT/DELETE | CategoryController | CategoryService | CategoryRepository |
| /products (CRUD) | GET/POST/GET/PUT/DELETE | ProductController | ProductService | ProductRepository |
| /bahan-baku (CRUD) | GET/POST/GET/PUT/DELETE | ProductController?→Ingredient | IngredientService | IngredientRepository |
| /stok-bahan (CRUD) | GET/POST/GET/PUT/DELETE | StockController | StockService | StockRepository |
| /meja (CRUD) | GET/POST/GET/PUT/DELETE | TableController | TableService | TableRepository |
| /shifts/active | GET | ShiftController@active | ShiftService | ShiftRepository |
| /shifts/open | POST | ShiftController@open | ShiftService | ShiftRepository, PettyCashRepository |
| /shifts/{id}/petty-cash | POST | ShiftController@pettyCash | ShiftService | PettyCashRepository |
| /shifts/{id}/close | POST | ShiftController@close | ShiftService, ClosingService | ShiftRepository, ClosingRepository |
| /shifts/history | GET | ShiftController@history | ShiftService | ShiftRepository |
| /transaksi (store/index/show) | POST/GET/GET | TransactionController | TransactionService | TransactionRepository, DetailRepository, ProductRepository |
| /transaksi/{id} (update) | PUT | TransactionController@update | TransactionService | TransactionRepository, DetailRepository, ProductRepository |
| /transaksi/{id}/void | POST | TransactionController@void | TransactionService | TransactionRepository |
| /transaksi/{id}/pembayaran | POST | PaymentController@pay | PaymentService | PaymentRepository, Transaction model lock, PaymentMethod |
| /pengeluaran (CRUD) | GET/POST/GET/PUT/DELETE | ExpenseController | ExpenseService | ExpenseRepository |
| /shifts/{id}/closing | POST | ClosingController@store | ClosingService | ClosingRepository, ShiftRepository |
| /closing/history | GET | ClosingController@history | ClosingService | ClosingRepository |
| /reports/daily | GET | ReportController@daily | ReportService | Transaction, Payment, Expense |
| /reports/monthly | GET | ReportController@monthly | ReportService | Transaction, Payment |
| /reports/statistics | GET | ReportController@statistics | ReportService | Transaction, Detail, Product |
| /reports/last-7-days | GET | ReportController@last7Days | ReportService | Transaction |

## Middleware
- `auth:sanctum` → all except login.
- `role:Admin` → categories, products, bahan-baku, stok-bahan, meja, transaksi index/show (monitor), void, reports/admin, dashboard/admin, closing/history, shifts/history.
- `role:Kasir` → shifts open/close/petty, transaksi store/update, pembayaran, pengeluaran, reports/daily, last-7-days, dashboard/cashier.
- `GET /transaksi/{id}` → Admin dapat melihat semua; Kasir hanya dapat melihat transaksi miliknya sendiri.

## Dependency Injection
`RepositoryServiceProvider` binds each `*RepositoryInterface` → `*Repository` (Eloquent). Services receive repositories via constructor injection. Controllers receive services via constructor injection. Registered in `AppServiceProvider` / `bootstrap/app.php` route/scan groups.

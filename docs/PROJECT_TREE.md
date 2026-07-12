# Full Project Tree — SUSHIMOO POS

```
sushimoo-pos/
├── backend/
│   └── laravel-api/
│       ├── app/
│       │   ├── Console/Kernel.php
│       │   ├── Exceptions/Handler.php
│       │   ├── Helpers/ApiResponse.php
│       │   ├── Http/
│       │   │   ├── Controllers/
│       │   │   │   ├── Controller.php          (base)
│       │   │   │   ├── Auth/AuthController.php
│       │   │   │   ├── Dashboard/DashboardController.php
│       │   │   │   ├── Category/CategoryController.php
│       │   │   │   ├── Product/ProductController.php
│       │   │   │   ├── Table/TableController.php
│       │   │   │   ├── Shift/ShiftController.php
│       │   │   │   ├── Transaction/TransactionController.php
│       │   │   │   ├── Payment/PaymentController.php
│       │   │   │   ├── Expense/ExpenseController.php
│       │   │   │   ├── Closing/ClosingController.php
│       │   │   │   └── Report/ReportController.php
│       │   │   ├── Middleware/
│       │   │   │   ├── EnsureRole.php
│       │   │   │   └── ForceJson.php
│       │   │   ├── Requests/
│       │   │   │   ├── Auth/{LoginRequest,LogoutRequest}.php
│       │   │   │   ├── Category/CategoryRequest.php
│       │   │   │   ├── Product/ProductRequest.php
│       │   │   │   ├── Table/TableRequest.php
│       │   │   │   ├── Shift/{OpenShiftRequest,CloseShiftRequest,PettyCashRequest}.php
│       │   │   │   ├── Transaction/{StoreTransactionRequest,UpdateTransactionRequest,VoidTransactionRequest}.php
│       │   │   │   ├── Payment/PaymentRequest.php
│       │   │   │   ├── Expense/ExpenseRequest.php
│       │   │   │   └── Report/ReportRequest.php
│       │   │   └── Kernel.php
│       │   ├── Models/
│       │   │   ├── Role.php  User.php  Category.php  Product.php
│       │   │   ├── Ingredient.php  Stock.php  Recipe.php  Table.php
│       │   │   ├── Shift.php  PettyCash.php  Transaction.php
│       │   │   ├── TransactionDetail.php  PaymentMethod.php  Payment.php
│       │   │   ├── Expense.php  Closing.php  ActivityLog.php
│       │   ├── Providers/{AppServiceProvider,RouteServiceProvider,AuthServiceProvider}.php
│       │   ├── Repositories/
│       │   │   ├── Contracts/{*RepositoryInterface}.php
│       │   │   ├── Eloquent/{*Repository}.php
│       │   │   └── RepositoryServiceProvider.php
│       │   ├── Services/
│       │   │   ├── AuthService.php  DashboardService.php
│       │   │   ├── CategoryService.php  ProductService.php
│       │   │   ├── TableService.php  ShiftService.php
│       │   │   ├── TransactionService.php  PaymentService.php
│       │   │   ├── ExpenseService.php  ClosingService.php
│       │   │   └── ReportService.php
│       │   └── Support/PrinterService.php
│       ├── bootstrap/{app.php,cache/}
│       ├── config/{app,database,cors,sanctum,auth}.php
│       ├── database/
│       │   ├── migrations/*.php   (mirror schema.sql)
│       │   ├── seeders/{DatabaseSeeder,RoleSeeder,PaymentMethodSeeder,TableSeeder,UserSeeder}.php
│       │   └── factories/*.php
│       ├── routes/{api.php,web.php}
│       ├── storage/app/.gitignore
│       ├── tests/{Feature,Unit,Integration}/*.php
│       ├── composer.json  .env.example  artisan  phpunit.xml
│       └── README.md
│
├── mobile/
│   └── flutter-pos/
│       ├── lib/
│       │   ├── app/
│       │   │   ├── routes/app_pages.dart  app_routes.dart
│       │   │   ├── bindings/initial_binding.dart
│       │   │   ├── constants/{app_constants,colors,strings,dimensions}.dart
│       │   │   ├── themes/theme.dart
│       │   │   └── services/{api_client,storage_service,auth_service,printer_service}.dart
│       │   ├── data/
│       │   │   ├── models/*.dart
│       │   │   ├── providers/*.dart
│       │   │   ├── repositories/*.dart
│       │   │   └── response/api_response.dart
│       │   ├── modules/
│       │   │   ├── splash/   {bindings,controllers,views}
│       │   │   ├── login/    {bindings,controllers,views,widgets}
│       │   │   ├── dashboard/{bindings,controllers,views,widgets}
│       │   │   ├── category/ {bindings,controllers,views,widgets}
│       │   │   ├── product/  {bindings,controllers,views,widgets}
│       │   │   ├── ingredient/{bindings,controllers,views,widgets}
│       │   │   ├── stock/    {bindings,controllers,views,widgets}
│       │   │   ├── table/    {bindings,controllers,views,widgets}
│       │   │   ├── shift/    {bindings,controllers,views,widgets}
│       │   │   ├── pos/      {bindings,controllers,views,widgets}
│       │   │   ├── payment/  {bindings,controllers,views,widgets}
│       │   │   ├── expense/  {bindings,controllers,views,widgets}
│       │   │   ├── report/   {bindings,controllers,views,widgets}
│       │   │   ├── closing/  {bindings,controllers,views,widgets}
│       │   │   └── setting/  {bindings,controllers,views}
│       │   ├── shared/
│       │   │   ├── widgets/{app_button,app_text_field,app_card,app_dialog,app_loading,app_empty_state,app_data_table,app_sidebar,app_chip}.dart
│       │   │   ├── dialogs/*.dart
│       │   │   ├── extensions/*.dart
│       │   │   └── utils/*.dart
│       │   └── main.dart
│       ├── assets/images/{logo,splash,empty}.png
│       ├── pubspec.yaml  analysis_options.yaml  README.md
│       └── test/*.dart
│
├── database/
│   ├── schema.sql   seed.sql   erd.drawio
├── docs/  (this folder)
└── assets/
```

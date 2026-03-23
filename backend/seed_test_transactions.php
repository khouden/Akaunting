<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$company_id = 1;

// Get an account
$account = App\Models\Banking\Account::first();
if (!$account) {
    echo "No account found, seeding...\n";
    $account = App\Models\Banking\Account::create([
        'company_id' => $company_id,
        'name' => 'Cash',
        'number' => '123456789',
        'currency_code' => 'USD',
        'opening_balance' => 0,
        'enabled' => 1,
        'created_from' => 'tinker',
        'created_by' => 1
    ]);
}

// Get categories
$income_cat = App\Models\Setting\Category::where('type', 'income')->first();
$expense_cat = App\Models\Setting\Category::where('type', 'expense')->first();

if (!$income_cat) {
    $income_cat = App\Models\Setting\Category::create(['company_id' => $company_id, 'name' => 'Sales', 'type' => 'income', 'color' => '#6DA252', 'enabled' => 1]);
}
if (!$expense_cat) {
    $expense_cat = App\Models\Setting\Category::create(['company_id' => $company_id, 'name' => 'Supplies', 'type' => 'expense', 'color' => '#E46A76', 'enabled' => 1]);
}

// Default payment method
$pm = 'offline-payments.cash';

// Add Income for this month
App\Models\Banking\Transaction::create([
    'company_id' => $company_id,
    'account_id' => $account->id,
    'type' => 'income',
    'number' => 'INC-' . rand(1000, 9999),
    'paid_at' => now()->startOfMonth()->addDays(2),
    'amount' => 5000,
    'currency_code' => $account->currency_code,
    'currency_rate' => 1,
    'category_id' => $income_cat->id,
    'payment_method' => $pm,
    'created_from' => 'tinker',
    'created_by' => 1
]);

// Add Income for last month
App\Models\Banking\Transaction::create([
    'company_id' => $company_id,
    'account_id' => $account->id,
    'type' => 'income',
    'number' => 'INC-' . rand(1000, 9999),
    'paid_at' => now()->subMonth()->startOfMonth()->addDays(5),
    'amount' => 3200,
    'currency_code' => $account->currency_code,
    'currency_rate' => 1,
    'category_id' => $income_cat->id,
    'payment_method' => $pm,
    'created_from' => 'tinker',
    'created_by' => 1
]);

// Add Expense this month
App\Models\Banking\Transaction::create([
    'company_id' => $company_id,
    'account_id' => $account->id,
    'type' => 'expense',
    'number' => 'EXP-' . rand(1000, 9999),
    'paid_at' => now()->startOfMonth()->addDays(10),
    'amount' => 1500,
    'currency_code' => $account->currency_code,
    'currency_rate' => 1,
    'category_id' => $expense_cat->id,
    'payment_method' => $pm,
    'created_from' => 'tinker',
    'created_by' => 1
]);

echo "Test transactions injected successfully!\n";

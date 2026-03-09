<?php

namespace Database\Seeds;

use App\Models\Common\Company;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Artisan;

class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        // Temporarily mark app as not installed to bypass plan checks
        $installed = config('app.installed');
        config(['app.installed' => false]);

        $this->call(Permissions::class);

        // Create company directly
        $company = Company::create([
            'domain'     => '',
            'enabled'    => 1,
            'created_from' => 'core::seed',
        ]);

        // Store company settings (name, email, etc.)
        $company->makeCurrent();
        setting()->set([
            'company.name'  => 'My Company',
            'company.email' => 'admin@company.com',
            'default.locale'   => 'en-GB',
            'default.currency' => 'USD',
        ]);
        setting()->save();

        // Seed company data (accounts, categories, currencies, etc.)
        Artisan::call('company:seed', ['company' => $company->id]);

        // Create admin user
        $user = user_model_class()::create([
            'name'     => 'Admin',
            'email'    => 'admin@company.com',
            'password' => '123456',
            'locale'   => 'en-GB',
            'enabled'  => 1,
        ]);

        $user->companies()->attach($company->id);
        $user->roles()->attach(1);

        // Seed user data (dashboards)
        Artisan::call('user:seed', [
            'user'    => $user->id,
            'company' => $company->id,
        ]);

        config(['app.installed' => $installed]);
    }
}

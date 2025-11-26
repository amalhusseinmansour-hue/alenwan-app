<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Filament\Navigation\NavigationGroup;
use Filament\View\PanelsRenderHook;
use App\Http\Middleware\SetLocale;
use Illuminate\Support\Facades\Blade;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            // ✅ استخدام Filament's built-in login (مهم جداً للـ CRUD operations)
            ->login()
            ->colors([
                'primary' => Color::Amber,
            ])
            // Brand
            ->brandName('Alenwan')
            ->brandLogo(asset('logo.jpg'))
            ->brandLogoHeight('3rem')
            ->favicon(asset('logo.jpg'))
            // Database notifications
            ->databaseNotifications()
            ->databaseNotificationsPolling('30s')
            // Navigation
            ->navigationGroups([
                NavigationGroup::make()
                    ->label(fn () => __('filament.navigation.groups.content'))
                    ->collapsed(false),
                NavigationGroup::make()
                    ->label(fn () => __('filament.navigation.groups.users'))
                    ->collapsed(false),
                NavigationGroup::make()
                    ->label(fn () => __('filament.navigation.groups.configuration'))
                    ->collapsed(true),
                NavigationGroup::make()
                    ->label(fn () => __('filament.navigation.groups.reports'))
                    ->collapsed(true),
            ])
            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\\Filament\\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\\Filament\\Pages')
            ->pages([
                // Dashboard removed from navigation
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                Widgets\AccountWidget::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
                SetLocale::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ])
            // Global search
            ->globalSearchKeyBindings(['command+k', 'ctrl+k'])
            // ✅ تعطيل SPA mode مؤقتاً لحل مشاكل الحفظ
            // ->spa()
            // Render hooks for navbar items
            ->renderHook(
                PanelsRenderHook::USER_MENU_BEFORE,
                fn (): string => view('filament.components.language-switcher')->render()
            )
            // RTL Support
            ->renderHook(
                PanelsRenderHook::HEAD_END,
                fn (): string => view('filament.components.rtl-support')->render()
            );
    }
}

<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\WebAppController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Webapp Routes - Main Website
Route::get('/', [WebAppController::class, 'index'])->name('webapp.index');
Route::get('/movies', [WebAppController::class, 'movies'])->name('webapp.movies');
Route::get('/movie/{id}', [WebAppController::class, 'movie'])->name('webapp.movie');
Route::get('/series', [WebAppController::class, 'seriesList'])->name('webapp.series-list');
Route::get('/series/{id}', [WebAppController::class, 'series'])->name('webapp.series');
Route::get('/live', [WebAppController::class, 'liveStreams'])->name('webapp.live');
Route::get('/live/{id}', [WebAppController::class, 'liveStream'])->name('webapp.live-stream');
Route::get('/sports', [WebAppController::class, 'sports'])->name('webapp.sports');
Route::get('/sport/{id}', [WebAppController::class, 'sport'])->name('webapp.sport');
Route::get('/documentaries', [WebAppController::class, 'documentaries'])->name('webapp.documentaries');
Route::get('/documentary/{id}', [WebAppController::class, 'documentary'])->name('webapp.documentary');
Route::get('/cartoons', [WebAppController::class, 'cartoons'])->name('webapp.cartoons');
Route::get('/cartoon/{id}', [WebAppController::class, 'cartoon'])->name('webapp.cartoon');
Route::get('/podcasts', [WebAppController::class, 'podcasts'])->name('webapp.podcasts');

// Support Pages
Route::get('/help-center', [WebAppController::class, 'helpCenter'])->name('webapp.help-center');
Route::get('/contact', [WebAppController::class, 'contactUs'])->name('webapp.contact');
Route::get('/faq', [WebAppController::class, 'faq'])->name('webapp.faq');
Route::get('/download-app', [WebAppController::class, 'downloadApp'])->name('webapp.download-app');

// Legal Pages
Route::get('/terms', [WebAppController::class, 'terms'])->name('webapp.terms');
Route::get('/privacy', [WebAppController::class, 'privacy'])->name('webapp.privacy');
Route::get('/cookies', [WebAppController::class, 'cookies'])->name('webapp.cookies');

// Auth Pages
Route::get('/login', [WebAppController::class, 'login'])->name('webapp.login');
Route::post('/login', [App\Http\Controllers\AuthController::class, 'login'])->name('webapp.login.submit');
Route::get('/register', [WebAppController::class, 'register'])->name('webapp.register');
Route::post('/register', [App\Http\Controllers\AuthController::class, 'register'])->name('webapp.register.submit');
Route::post('/logout', [App\Http\Controllers\AuthController::class, 'logout'])->name('webapp.logout');

// Subscription Routes
Route::get('/subscribe', [App\Http\Controllers\SubscriptionController::class, 'index'])->name('webapp.subscribe');
Route::post('/subscribe/checkout', [App\Http\Controllers\SubscriptionController::class, 'checkout'])->name('webapp.subscribe.checkout');
Route::get('/subscription/callback', [App\Http\Controllers\SubscriptionController::class, 'callback'])->name('webapp.subscription.callback');
Route::get('/my-subscription', [App\Http\Controllers\SubscriptionController::class, 'mySubscription'])->name('webapp.my-subscription');
Route::post('/subscription/cancel', [App\Http\Controllers\SubscriptionController::class, 'cancel'])->name('webapp.subscription.cancel');

// ✅ Admin Panel - Filament
// تم إزالة custom login routes لأننا نستخدم Filament's built-in login
// Filament سيوفر تلقائياً:
// - GET  /admin/login
// - POST /admin/login
// - POST /admin/logout

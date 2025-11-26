<?php

use App\Http\Controllers\Api\OmdbApiController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| OMDB API Routes
|--------------------------------------------------------------------------
|
| أضف هذه المسارات إلى ملف routes/api.php
|
*/

// OMDB Routes - متاحة للجميع أو حسب middleware
Route::prefix('omdb')->name('omdb.')->group(function () {

    // البحث العام
    Route::get('search', [OmdbApiController::class, 'search'])->name('search');

    // البحث عن أفلام فقط
    Route::get('movies', [OmdbApiController::class, 'searchMovies'])->name('movies');

    // البحث عن مسلسلات فقط
    Route::get('series', [OmdbApiController::class, 'searchSeries'])->name('series');

    // الحصول على تفاصيل
    Route::get('details/{imdbId}', [OmdbApiController::class, 'details'])->name('details');
});

/*
|--------------------------------------------------------------------------
| أمثلة الاستخدام من التطبيق:
|--------------------------------------------------------------------------
|
| 1. البحث العام:
|    GET /api/omdb/search?query=Batman&page=1
|    GET /api/omdb/search?query=Batman&type=movie&page=1
|
| 2. البحث عن أفلام:
|    GET /api/omdb/movies?query=Avengers&page=1
|
| 3. البحث عن مسلسلات:
|    GET /api/omdb/series?query=Breaking Bad&page=1
|
| 4. تفاصيل محتوى:
|    GET /api/omdb/details/tt0468569
|
|--------------------------------------------------------------------------
| إذا كنت تريد حماية هذه المسارات بـ authentication:
|--------------------------------------------------------------------------
|
| Route::middleware('auth:sanctum')->prefix('omdb')->group(function () {
|     // المسارات هنا
| });
|
*/

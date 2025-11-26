<?php

namespace App\Services;

use App\Models\Movie;
use App\Models\Series;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

class OmdbImportService
{
    protected string $apiKey = '2379d837';
    protected string $baseUrl = 'https://www.omdbapi.com/';

    /**
     * البحث عن محتوى في OMDB
     */
    public function search(string $query, string $type = '', int $page = 1): array
    {
        try {
            $params = [
                'apikey' => $this->apiKey,
                's' => $query,
                'page' => $page,
            ];

            if ($type) {
                $params['type'] = $type; // movie, series, episode
            }

            $response = Http::get($this->baseUrl, $params);

            if ($response->successful()) {
                $data = $response->json();

                if ($data['Response'] === 'True') {
                    return [
                        'success' => true,
                        'results' => $data['Search'] ?? [],
                        'totalResults' => (int)($data['totalResults'] ?? 0),
                    ];
                }
            }

            return [
                'success' => false,
                'error' => $data['Error'] ?? 'فشل البحث',
            ];

        } catch (\Exception $e) {
            Log::error('OMDB Search Error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * الحصول على تفاصيل كاملة لفيلم/مسلسل
     */
    public function getDetails(string $imdbId): array
    {
        try {
            $response = Http::get($this->baseUrl, [
                'apikey' => $this->apiKey,
                'i' => $imdbId,
                'plot' => 'full',
            ]);

            if ($response->successful()) {
                $data = $response->json();

                if ($data['Response'] === 'True') {
                    return [
                        'success' => true,
                        'data' => $data,
                    ];
                }
            }

            return [
                'success' => false,
                'error' => $data['Error'] ?? 'لم يتم العثور على المحتوى',
            ];

        } catch (\Exception $e) {
            Log::error('OMDB Details Error: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * استيراد فيلم من OMDB إلى قاعدة البيانات
     */
    public function importMovie(string $imdbId, int $categoryId, int $languageId = 1): ?Movie
    {
        try {
            $result = $this->getDetails($imdbId);

            if (!$result['success']) {
                throw new \Exception($result['error']);
            }

            $data = $result['data'];

            // التحقق من عدم وجود الفيلم مسبقاً
            $existingMovie = Movie::where('imdb_id', $imdbId)->first();
            if ($existingMovie) {
                return $existingMovie;
            }

            // تحضير البيانات
            $movieData = [
                'imdb_id' => $imdbId,
                'category_id' => $categoryId,
                'language_id' => $languageId,
                'title' => [
                    'ar' => $data['Title'] ?? 'بدون عنوان',
                    'en' => $data['Title'] ?? 'Untitled',
                ],
                'description' => [
                    'ar' => $data['Plot'] ?? 'لا يوجد وصف',
                    'en' => $data['Plot'] ?? 'No description',
                ],
                'slug' => Str::slug($data['Title'] ?? 'movie-' . time()),
                'year' => $this->extractYear($data['Year'] ?? ''),
                'duration' => $this->extractDuration($data['Runtime'] ?? ''),
                'rating' => $this->extractRating($data['imdbRating'] ?? '0'),
                'poster' => $this->getPosterUrl($data['Poster'] ?? ''),
                'trailer_url' => null, // يجب إضافته يدوياً
                'video_url' => null, // يجب إضافته يدوياً
                'director' => [
                    'ar' => $data['Director'] ?? 'غير معروف',
                    'en' => $data['Director'] ?? 'Unknown',
                ],
                'cast' => $data['Actors'] ?? '',
                'genres' => $data['Genre'] ?? '',
                'is_active' => true,
                'is_premium' => false,
                'is_featured' => false,
                'views_count' => 0,
            ];

            $movie = Movie::create($movieData);

            Log::info("Movie imported from OMDB: {$movie->title} (IMDb: {$imdbId})");

            return $movie;

        } catch (\Exception $e) {
            Log::error('OMDB Import Movie Error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * استيراد مسلسل من OMDB إلى قاعدة البيانات
     */
    public function importSeries(string $imdbId, int $categoryId, int $languageId = 1): ?Series
    {
        try {
            $result = $this->getDetails($imdbId);

            if (!$result['success']) {
                throw new \Exception($result['error']);
            }

            $data = $result['data'];

            // التحقق من أنه مسلسل
            if ($data['Type'] !== 'series') {
                throw new \Exception('هذا المحتوى ليس مسلسلاً');
            }

            // التحقق من عدم وجود المسلسل مسبقاً
            $existingSeries = Series::where('imdb_id', $imdbId)->first();
            if ($existingSeries) {
                return $existingSeries;
            }

            // تحضير البيانات
            $seriesData = [
                'imdb_id' => $imdbId,
                'category_id' => $categoryId,
                'language_id' => $languageId,
                'title' => [
                    'ar' => $data['Title'] ?? 'بدون عنوان',
                    'en' => $data['Title'] ?? 'Untitled',
                ],
                'description' => [
                    'ar' => $data['Plot'] ?? 'لا يوجد وصف',
                    'en' => $data['Plot'] ?? 'No description',
                ],
                'slug' => Str::slug($data['Title'] ?? 'series-' . time()),
                'year' => $this->extractYear($data['Year'] ?? ''),
                'rating' => $this->extractRating($data['imdbRating'] ?? '0'),
                'poster' => $this->getPosterUrl($data['Poster'] ?? ''),
                'trailer_url' => null,
                'director' => [
                    'ar' => $data['Director'] ?? 'غير معروف',
                    'en' => $data['Director'] ?? 'Unknown',
                ],
                'cast' => $data['Actors'] ?? '',
                'genres' => $data['Genre'] ?? '',
                'total_seasons' => (int)($data['totalSeasons'] ?? 0),
                'is_active' => true,
                'is_premium' => false,
                'is_featured' => false,
                'views_count' => 0,
            ];

            $series = Series::create($seriesData);

            Log::info("Series imported from OMDB: {$series->title} (IMDb: {$imdbId})");

            return $series;

        } catch (\Exception $e) {
            Log::error('OMDB Import Series Error: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * استخراج السنة من النص
     */
    protected function extractYear(string $year): ?int
    {
        // مثال: "2019" أو "2019–2024" أو "2019–"
        preg_match('/(\d{4})/', $year, $matches);
        return isset($matches[1]) ? (int)$matches[1] : null;
    }

    /**
     * استخراج المدة بالدقائق
     */
    protected function extractDuration(string $runtime): ?int
    {
        // مثال: "148 min"
        preg_match('/(\d+)/', $runtime, $matches);
        return isset($matches[1]) ? (int)$matches[1] : null;
    }

    /**
     * استخراج التقييم كرقم عشري
     */
    protected function extractRating(string $rating): float
    {
        $rating = str_replace(',', '.', $rating);
        return (float)$rating;
    }

    /**
     * الحصول على رابط البوستر
     */
    protected function getPosterUrl(string $poster): ?string
    {
        return ($poster && $poster !== 'N/A') ? $poster : null;
    }

    /**
     * استيراد متعدد (Bulk Import)
     */
    public function bulkImport(array $imdbIds, string $type, int $categoryId, int $languageId = 1): array
    {
        $results = [
            'success' => 0,
            'failed' => 0,
            'items' => [],
            'errors' => [],
        ];

        foreach ($imdbIds as $imdbId) {
            try {
                if ($type === 'movie') {
                    $item = $this->importMovie($imdbId, $categoryId, $languageId);
                } else {
                    $item = $this->importSeries($imdbId, $categoryId, $languageId);
                }

                if ($item) {
                    $results['success']++;
                    $results['items'][] = $item;
                } else {
                    $results['failed']++;
                    $results['errors'][] = "Failed to import: {$imdbId}";
                }

            } catch (\Exception $e) {
                $results['failed']++;
                $results['errors'][] = "{$imdbId}: {$e->getMessage()}";
            }
        }

        return $results;
    }
}

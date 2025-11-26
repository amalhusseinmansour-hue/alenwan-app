<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\OmdbImportService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class OmdbApiController extends Controller
{
    protected OmdbImportService $omdbService;

    public function __construct(OmdbImportService $omdbService)
    {
        $this->omdbService = $omdbService;
    }

    /**
     * البحث في OMDB
     *
     * GET /api/omdb/search
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function search(Request $request): JsonResponse
    {
        $request->validate([
            'query' => 'required|string|min:2',
            'type' => 'nullable|in:movie,series',
            'page' => 'nullable|integer|min:1',
        ]);

        $result = $this->omdbService->search(
            $request->input('query'),
            $request->input('type', ''),
            $request->input('page', 1)
        );

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'data' => [
                    'results' => $result['results'],
                    'total' => $result['totalResults'],
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => $result['error'],
        ], 400);
    }

    /**
     * الحصول على تفاصيل محتوى من OMDB
     *
     * GET /api/omdb/details/{imdbId}
     *
     * @param string $imdbId
     * @return JsonResponse
     */
    public function details(string $imdbId): JsonResponse
    {
        $result = $this->omdbService->getDetails($imdbId);

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'data' => $result['data'],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => $result['error'],
        ], 404);
    }

    /**
     * البحث عن أفلام فقط
     *
     * GET /api/omdb/movies
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function searchMovies(Request $request): JsonResponse
    {
        $request->validate([
            'query' => 'required|string|min:2',
            'page' => 'nullable|integer|min:1',
        ]);

        $result = $this->omdbService->search(
            $request->input('query'),
            'movie',
            $request->input('page', 1)
        );

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'data' => [
                    'results' => $result['results'],
                    'total' => $result['totalResults'],
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => $result['error'],
        ], 400);
    }

    /**
     * البحث عن مسلسلات فقط
     *
     * GET /api/omdb/series
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function searchSeries(Request $request): JsonResponse
    {
        $request->validate([
            'query' => 'required|string|min:2',
            'page' => 'nullable|integer|min:1',
        ]);

        $result = $this->omdbService->search(
            $request->input('query'),
            'series',
            $request->input('page', 1)
        );

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'data' => [
                    'results' => $result['results'],
                    'total' => $result['totalResults'],
                ],
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => $result['error'],
        ], 400);
    }
}

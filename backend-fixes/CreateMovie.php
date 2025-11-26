<?php

namespace App\Filament\Resources\MovieResource\Pages;

use App\Filament\Resources\MovieResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateMovie extends CreateRecord
{
    protected static string $resource = MovieResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Handle translatable fields (title, description, etc.)
        // Spatie Translatable expects array format - no conversion needed

        // Generate slug from Arabic title if not provided
        if (empty($data['slug'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'movie-' . time());
        }

        // Set default values if not provided
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['rating'] = $data['rating'] ?? 0.0;
        $data['views_count'] = $data['views_count'] ?? 0;

        return $data;
    }

    /**
     * Redirect after create
     */
    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

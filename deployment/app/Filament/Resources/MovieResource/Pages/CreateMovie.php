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
     * Convert translatable fields from dot notation to array
     */
    protected function convertTranslatableFields(array $data, array $fields): array
    {
        foreach ($fields as $field) {
            $translations = [];
            foreach (['ar', 'en'] as $locale) {
                $key = "{$field}.{$locale}";
                if (isset($data[$key])) {
                    $translations[$locale] = $data[$key];
                    unset($data[$key]);
                }
            }
            if (!empty($translations)) {
                $data[$field] = $translations;
            }
        }
        return $data;
    }

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Convert translatable fields: title.ar -> title['ar']
        $data = $this->convertTranslatableFields($data, ['title', 'description', 'director']);

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

<?php

namespace App\Filament\Resources\SeriesResource\Pages;

use App\Filament\Resources\SeriesResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateSeries extends CreateRecord
{
    protected static string $resource = SeriesResource::class;

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

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data = $this->convertTranslatableFields($data, ['title', 'description', 'director']);

        if (empty($data['slug'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'series-' . time());
        }

        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['rating'] = $data['rating'] ?? 0.0;
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['status'] = $data['status'] ?? 'ongoing';

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

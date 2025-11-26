<?php

namespace App\Filament\Resources\LiveStreamResource\Pages;

use App\Filament\Resources\LiveStreamResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateLiveStream extends CreateRecord
{
    protected static string $resource = LiveStreamResource::class;

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
        $data = $this->convertTranslatableFields($data, ['title', 'description']);

        if (empty($data['slug'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'live-' . time());
        }

        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_live'] = $data['is_live'] ?? false;
        $data['platform'] = $data['platform'] ?? 'youtube';
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['likes_count'] = $data['likes_count'] ?? 0;

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

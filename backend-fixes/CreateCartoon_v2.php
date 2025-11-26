<?php

namespace App\Filament\Resources\CartoonResource\Pages;

use App\Filament\Resources\CartoonResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateCartoon extends CreateRecord
{
    protected static string $resource = CartoonResource::class;

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
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'cartoon-' . time());
        }

        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['views_count'] = $data['views_count'] ?? 0;

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

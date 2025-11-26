<?php

namespace App\Filament\Resources\ChannelResource\Pages;

use App\Filament\Resources\ChannelResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateChannel extends CreateRecord
{
    protected static string $resource = ChannelResource::class;

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
        $data = $this->convertTranslatableFields($data, ['name', 'description']);

        if (empty($data['slug'])) {
            $nameAr = $data['name']['ar'] ?? null;
            $nameEn = $data['name']['en'] ?? null;
            $data['slug'] = Str::slug($nameAr ?: $nameEn ?: 'channel-' . time());
        }

        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['is_live'] = $data['is_live'] ?? false;
        $data['platform'] = $data['platform'] ?? 'youtube';
        $data['subscribers_count'] = $data['subscribers_count'] ?? 0;
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['videos_count'] = $data['videos_count'] ?? 0;
        $data['order'] = $data['order'] ?? 0;

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

<?php

namespace App\Filament\Resources\ChannelResource\Pages;

use App\Filament\Resources\ChannelResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateChannel extends CreateRecord
{
    protected static string $resource = ChannelResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Handle translatable name field
        if (isset($data['name']) && is_array($data['name'])) {
            // Spatie Translatable expects array format
            // No conversion needed
        }

        // Handle translatable description field
        if (isset($data['description']) && is_array($data['description'])) {
            // Spatie Translatable expects array format
            // No conversion needed
        }

        // Generate slug from Arabic name if not provided
        if (empty($data['slug'])) {
            $nameAr = $data['name']['ar'] ?? null;
            $nameEn = $data['name']['en'] ?? null;
            $data['slug'] = Str::slug($nameAr ?: $nameEn ?: 'channel-' . time());
        }

        // Set default values if not provided
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_live'] = $data['is_live'] ?? false;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['order'] = $data['order'] ?? 0;
        $data['subscribers_count'] = $data['subscribers_count'] ?? 0;
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['videos_count'] = $data['videos_count'] ?? 0;

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

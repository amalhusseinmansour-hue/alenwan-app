<?php

namespace App\Filament\Resources\CartoonResource\Pages;

use App\Filament\Resources\CartoonResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateCartoon extends CreateRecord
{
    protected static string $resource = CartoonResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Set default values if not provided
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_published'] = $data['is_published'] ?? true;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['is_series'] = $data['is_series'] ?? false;
        $data['has_audio_translation'] = $data['has_audio_translation'] ?? false;
        $data['default_audio_language'] = $data['default_audio_language'] ?? 'ar';
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['rating'] = $data['rating'] ?? 0.0;

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

<?php

namespace App\Filament\Resources\SportResource\Pages;

use App\Filament\Resources\SportResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateSport extends CreateRecord
{
    protected static string $resource = SportResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Set default values if not provided
        $data['is_live'] = $data['is_live'] ?? false;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['has_audio_translation'] = $data['has_audio_translation'] ?? false;
        $data['default_audio_language'] = $data['default_audio_language'] ?? 'ar';

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

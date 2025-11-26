<?php

namespace App\Filament\Resources\DocumentaryResource\Pages;

use App\Filament\Resources\DocumentaryResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateDocumentary extends CreateRecord
{
    protected static string $resource = DocumentaryResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Set default values if not provided
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['has_audio_translation'] = $data['has_audio_translation'] ?? false;
        $data['default_audio_language'] = $data['default_audio_language'] ?? 'ar';
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

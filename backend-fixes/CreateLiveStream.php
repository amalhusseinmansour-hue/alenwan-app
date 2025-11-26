<?php

namespace App\Filament\Resources\LiveStreamResource\Pages;

use App\Filament\Resources\LiveStreamResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Str;

class CreateLiveStream extends CreateRecord
{
    protected static string $resource = LiveStreamResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // Handle translatable fields (title, description)
        // Spatie Translatable expects array format - no conversion needed

        // Generate slug from Arabic title if not provided
        if (empty($data['slug'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'stream-' . time());
        }

        // Set default values if not provided
        $data['platform'] = $data['platform'] ?? 'youtube';
        $data['stream_type'] = $data['stream_type'] ?? 'live';
        $data['has_audio_translation'] = $data['has_audio_translation'] ?? false;
        $data['default_audio_language'] = $data['default_audio_language'] ?? 'ar';
        $data['views_count'] = $data['views_count'] ?? 0;
        $data['likes_count'] = $data['likes_count'] ?? 0;
        $data['concurrent_viewers'] = $data['concurrent_viewers'] ?? 0;

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

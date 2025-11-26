<?php

namespace App\Filament\Resources\LiveStreamResource\Pages;

use App\Filament\Resources\LiveStreamResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Str;

class EditLiveStream extends EditRecord
{
    protected static string $resource = LiveStreamResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    /**
     * Mutate form data before filling
     */
    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Spatie Translatable automatically handles JSON to array conversion
        return $data;
    }

    /**
     * Mutate form data before saving
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        // Handle translatable fields
        // Spatie Translatable expects array format - no conversion needed

        // Update slug if title changed and slug is empty
        if (empty($data['slug']) && isset($data['title'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'stream-' . time());
        }

        return $data;
    }

    /**
     * Redirect after save
     */
    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

<?php

namespace App\Filament\Resources\SeriesResource\Pages;

use App\Filament\Resources\SeriesResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Str;

class EditSeries extends EditRecord
{
    protected static string $resource = SeriesResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
            Actions\ForceDeleteAction::make(),
            Actions\RestoreAction::make(),
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
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'series-' . time());
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

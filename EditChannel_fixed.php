<?php

namespace App\Filament\Resources\ChannelResource\Pages;

use App\Filament\Resources\ChannelResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Str;

class EditChannel extends EditRecord
{
    protected static string $resource = ChannelResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    /**
     * Mutate form data before filling
     * This ensures the form displays existing data correctly
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

        // Update slug if name changed and slug is empty
        if (empty($data['slug']) && isset($data['name'])) {
            $nameAr = $data['name']['ar'] ?? null;
            $nameEn = $data['name']['en'] ?? null;
            $data['slug'] = Str::slug($nameAr ?: $nameEn ?: 'channel-' . time());
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

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

    protected function mutateFormDataBeforeSave(array $data): array
    {
        $data = $this->convertTranslatableFields($data, ['name', 'description']);

        if (empty($data['slug']) && isset($data['name'])) {
            $nameAr = $data['name']['ar'] ?? null;
            $nameEn = $data['name']['en'] ?? null;
            $data['slug'] = Str::slug($nameAr ?: $nameEn ?: 'channel-' . time());
        }

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

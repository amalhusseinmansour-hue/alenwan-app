<?php

namespace App\Filament\Resources\SportResource\Pages;

use App\Filament\Resources\SportResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Str;

class EditSport extends EditRecord
{
    protected static string $resource = SportResource::class;

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
        $data = $this->convertTranslatableFields($data, ['title', 'description']);

        if (empty($data['slug']) && isset($data['title'])) {
            $titleAr = $data['title']['ar'] ?? null;
            $titleEn = $data['title']['en'] ?? null;
            $data['slug'] = Str::slug($titleAr ?: $titleEn ?: 'sport-' . time());
        }

        return $data;
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

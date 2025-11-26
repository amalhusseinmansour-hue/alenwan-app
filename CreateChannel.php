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
        // Generate slug from name if not provided
        if (empty($data['slug']) && !empty($data['name'])) {
            $name = is_array($data['name']) ? ($data['name']['ar'] ?? $data['name']['en'] ?? '') : $data['name'];
            $data['slug'] = Str::slug($name);
        }

        // Set default values
        $data['is_active'] = $data['is_active'] ?? true;
        $data['is_live'] = $data['is_live'] ?? false;
        $data['is_premium'] = $data['is_premium'] ?? false;
        $data['is_featured'] = $data['is_featured'] ?? false;
        $data['order'] = $data['order'] ?? 0;

        // Initialize counters
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

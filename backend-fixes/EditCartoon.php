<?php

namespace App\Filament\Resources\CartoonResource\Pages;

use App\Filament\Resources\CartoonResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditCartoon extends EditRecord
{
    protected static string $resource = CartoonResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    /**
     * Redirect after save
     */
    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}

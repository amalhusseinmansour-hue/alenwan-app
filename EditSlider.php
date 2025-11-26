<?php

namespace App\Filament\Resources\SliderResource\Pages;

use App\Filament\Resources\SliderResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSlider extends EditRecord
{
    protected static string $resource = SliderResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }

    /**
     * Mutate form data before saving
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        // إذا كان نوع الميديا صورة، امسح بيانات الفيديو
        if (isset($data['media_type']) && $data['media_type'] === 'image') {
            $data['video_url'] = null;
            $data['video_type'] = null;
        }

        // إذا كان نوع الميديا فيديو، امسح بيانات الصورة
        if (isset($data['media_type']) && $data['media_type'] === 'video') {
            $data['image'] = null;
        }

        // مسح الحقول غير المستخدمة حسب النوع
        if (isset($data['type'])) {
            switch ($data['type']) {
                case 'movie':
                    $data['series_id'] = null;
                    $data['category_id'] = null;
                    $data['url'] = null;
                    break;
                case 'series':
                    $data['movie_id'] = null;
                    $data['category_id'] = null;
                    $data['url'] = null;
                    break;
                case 'category':
                    $data['movie_id'] = null;
                    $data['series_id'] = null;
                    $data['url'] = null;
                    break;
                case 'url':
                    $data['movie_id'] = null;
                    $data['series_id'] = null;
                    $data['category_id'] = null;
                    break;
            }
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

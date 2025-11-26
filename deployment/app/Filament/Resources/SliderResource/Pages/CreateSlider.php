<?php

namespace App\Filament\Resources\SliderResource\Pages;

use App\Filament\Resources\SliderResource;
use Filament\Actions;
use Filament\Resources\Pages\CreateRecord;

class CreateSlider extends CreateRecord
{
    protected static string $resource = SliderResource::class;

    /**
     * Mutate form data before creating
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        // إذا كان نوع الميديا صورة، امسح بيانات الفيديو
        if (isset($data['media_type']) && $data['media_type'] === 'image') {
            $data['video_url'] = null;
            $data['video_type'] = null;
        }

        // إذا كان نوع الميديا فيديو، تأكد من وجود صورة افتراضية
        if (isset($data['media_type']) && $data['media_type'] === 'video') {
            // إذا لم يتم رفع صورة، استخدم صورة افتراضية
            if (empty($data['image'])) {
                $data['image'] = 'default-slider.jpg';
            }
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

        // تعيين قيم افتراضية
        $data['is_active'] = $data['is_active'] ?? true;
        $data['order'] = $data['order'] ?? 0;

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

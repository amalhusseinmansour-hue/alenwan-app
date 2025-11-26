<?php

namespace App\Filament\Pages;

use App\Services\OmdbImportService;
use App\Models\Category;
use App\Models\Language;
use Filament\Pages\Page;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Radio;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Notifications\Notification;
use Filament\Forms\Form;

class OmdbImportPage extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-down-tray';
    protected static ?string $navigationLabel = 'استيراد من IMDb';
    protected static ?string $navigationGroup = 'إدارة المحتوى';
    protected static string $view = 'filament.pages.omdb-import-page';
    protected static ?int $navigationSort = 100;

    public ?array $data = [];
    public array $searchResults = [];
    public ?string $selectedImdbId = null;
    public ?array $selectedDetails = null;

    public function mount(): void
    {
        $this->form->fill();
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Radio::make('import_type')
                    ->label('نوع المحتوى')
                    ->options([
                        'movie' => 'فيلم',
                        'series' => 'مسلسل',
                    ])
                    ->required()
                    ->default('movie')
                    ->inline(),

                TextInput::make('search_query')
                    ->label('ابحث في IMDb')
                    ->placeholder('مثال: Batman, Avengers, Breaking Bad')
                    ->required()
                    ->suffixAction(
                        \Filament\Forms\Components\Actions\Action::make('search')
                            ->label('بحث')
                            ->icon('heroicon-o-magnifying-glass')
                            ->action('searchOmdb')
                    ),

                Select::make('category_id')
                    ->label('التصنيف')
                    ->options(Category::pluck('name', 'id'))
                    ->required()
                    ->searchable(),

                Select::make('language_id')
                    ->label('اللغة')
                    ->options(Language::pluck('name', 'id'))
                    ->default(1)
                    ->required(),

                Textarea::make('imdb_ids')
                    ->label('معرفات IMDb (للاستيراد المتعدد)')
                    ->placeholder("tt0468569\ntt0111161\ntt0137523")
                    ->helperText('ضع كل IMDb ID في سطر منفصل (مثال: tt0468569)')
                    ->rows(5),
            ])
            ->statePath('data');
    }

    /**
     * البحث في OMDB
     */
    public function searchOmdb(): void
    {
        $data = $this->form->getState();

        if (empty($data['search_query'])) {
            Notification::make()
                ->title('خطأ')
                ->body('الرجاء إدخال كلمة البحث')
                ->danger()
                ->send();
            return;
        }

        $service = new OmdbImportService();
        $result = $service->search(
            $data['search_query'],
            $data['import_type'] ?? ''
        );

        if ($result['success']) {
            $this->searchResults = $result['results'];

            Notification::make()
                ->title('نجح البحث')
                ->body("تم العثور على {$result['totalResults']} نتيجة")
                ->success()
                ->send();
        } else {
            $this->searchResults = [];

            Notification::make()
                ->title('فشل البحث')
                ->body($result['error'])
                ->danger()
                ->send();
        }
    }

    /**
     * عرض تفاصيل محتوى معين
     */
    public function viewDetails(string $imdbId): void
    {
        $service = new OmdbImportService();
        $result = $service->getDetails($imdbId);

        if ($result['success']) {
            $this->selectedImdbId = $imdbId;
            $this->selectedDetails = $result['data'];
        } else {
            Notification::make()
                ->title('خطأ')
                ->body($result['error'])
                ->danger()
                ->send();
        }
    }

    /**
     * استيراد محتوى واحد
     */
    public function importSingle(string $imdbId): void
    {
        $data = $this->form->getState();

        if (empty($data['category_id'])) {
            Notification::make()
                ->title('خطأ')
                ->body('الرجاء اختيار التصنيف')
                ->danger()
                ->send();
            return;
        }

        $service = new OmdbImportService();

        try {
            if ($data['import_type'] === 'movie') {
                $item = $service->importMovie(
                    $imdbId,
                    $data['category_id'],
                    $data['language_id'] ?? 1
                );
            } else {
                $item = $service->importSeries(
                    $imdbId,
                    $data['category_id'],
                    $data['language_id'] ?? 1
                );
            }

            if ($item) {
                Notification::make()
                    ->title('تم الاستيراد بنجاح')
                    ->body("تم استيراد: {$item->title}")
                    ->success()
                    ->send();

                // مسح نتائج البحث بعد الاستيراد
                $this->searchResults = array_filter(
                    $this->searchResults,
                    fn($result) => $result['imdbID'] !== $imdbId
                );
            } else {
                Notification::make()
                    ->title('فشل الاستيراد')
                    ->body('حدث خطأ أثناء الاستيراد')
                    ->danger()
                    ->send();
            }
        } catch (\Exception $e) {
            Notification::make()
                ->title('خطأ')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }

    /**
     * استيراد متعدد
     */
    public function bulkImport(): void
    {
        $data = $this->form->getState();

        if (empty($data['imdb_ids'])) {
            Notification::make()
                ->title('خطأ')
                ->body('الرجاء إدخال معرفات IMDb')
                ->danger()
                ->send();
            return;
        }

        if (empty($data['category_id'])) {
            Notification::make()
                ->title('خطأ')
                ->body('الرجاء اختيار التصنيف')
                ->danger()
                ->send();
            return;
        }

        // تقسيم المعرفات
        $imdbIds = array_filter(
            array_map('trim', explode("\n", $data['imdb_ids']))
        );

        if (empty($imdbIds)) {
            Notification::make()
                ->title('خطأ')
                ->body('لا توجد معرفات صالحة')
                ->danger()
                ->send();
            return;
        }

        $service = new OmdbImportService();

        try {
            $results = $service->bulkImport(
                $imdbIds,
                $data['import_type'],
                $data['category_id'],
                $data['language_id'] ?? 1
            );

            $message = "تم الاستيراد: {$results['success']}\nفشل: {$results['failed']}";

            if ($results['success'] > 0) {
                Notification::make()
                    ->title('اكتمل الاستيراد الجماعي')
                    ->body($message)
                    ->success()
                    ->send();

                // مسح الحقل بعد النجاح
                $this->form->fill(['imdb_ids' => '']);
            } else {
                Notification::make()
                    ->title('فشل الاستيراد')
                    ->body($message . "\n" . implode("\n", $results['errors']))
                    ->warning()
                    ->send();
            }
        } catch (\Exception $e) {
            Notification::make()
                ->title('خطأ')
                ->body($e->getMessage())
                ->danger()
                ->send();
        }
    }
}

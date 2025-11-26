<?php

namespace App\Filament\Resources;

use App\Filament\Resources\SliderResource\Pages;
use App\Filament\Resources\SliderResource\RelationManagers;
use App\Models\Slider;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

class SliderResource extends Resource
{
    protected static ?string $model = Slider::class;

    protected static ?string $navigationIcon = 'heroicon-o-photo';

    public static function getNavigationGroup(): ?string
    {
        return __('filament.navigation.groups.content');
    }

    public static function getNavigationLabel(): string
    {
        return 'السلايدر';
    }

    public static function getModelLabel(): string
    {
        return 'سلايد';
    }

    public static function getPluralModelLabel(): string
    {
        return 'السلايدر';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('المعلومات الأساسية')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label(__('filament.fields.title'))
                            ->maxLength(255),
                        Forms\Components\Textarea::make('description')
                            ->label(__('filament.fields.description'))
                            ->rows(3)
                            ->maxLength(500),
                    ])
                    ->columns(1),

                Forms\Components\Section::make('🎬 نوع المحتوى')
                    ->description('اختر نوع المحتوى: صورة ثابتة أو فيديو متحرك')
                    ->schema([
                        Forms\Components\Select::make('media_type')
                            ->label('نوع المحتوى')
                            ->options([
                                'image' => '🖼️ صورة (Image)',
                                'video' => '🎥 فيديو (Video)',
                            ])
                            ->default('image')
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(function ($state, callable $set) {
                                // ✅ إصلاح: لا نحذف الصورة عند اختيار فيديو
                                // لأن حقل image هو NOT NULL في قاعدة البيانات
                                if ($state === 'image') {
                                    // فقط امسح حقول الفيديو عند اختيار صورة
                                    $set('video_url', null);
                                    $set('video_type', null);
                                }
                                // عند اختيار فيديو، نبقي الصورة كما هي (thumbnail)
                            }),

                        // حقول الصورة (تظهر عند اختيار image)
                        Forms\Components\FileUpload::make('image')
                            ->label('الصورة')
                            ->image()
                            ->directory('sliders')
                            ->imageEditor()
                            ->imageCropAspectRatio('16:9')
                            ->maxSize(5120)
                            ->acceptedFileTypes(['image/jpeg', 'image/png', 'image/jpg', 'image/webp'])
                            ->disk('public')
                            ->visible(fn ($get) => $get('media_type') === 'image')
                            ->required(fn ($get) => $get('media_type') === 'image'),

                        // حقول الفيديو (تظهر عند اختيار video)
                        Forms\Components\Select::make('video_type')
                            ->label('نوع الفيديو')
                            ->options([
                                'youtube' => '📺 يوتيوب (YouTube)',
                                'vimeo' => '🎬 فيميو (Vimeo)',
                                'direct' => '🔗 رابط مباشر (MP4/M3U8)',
                            ])
                            ->visible(fn ($get) => $get('media_type') === 'video')
                            ->required(fn ($get) => $get('media_type') === 'video')
                            ->reactive()
                            ->helperText(function ($get) {
                                return match ($get('video_type')) {
                                    'youtube' => '📌 مثال: https://www.youtube.com/watch?v=VIDEO_ID',
                                    'vimeo' => '📌 مثال: https://vimeo.com/1234567',
                                    'direct' => '📌 مثال: https://example.com/video.mp4',
                                    default => '',
                                };
                            }),

                        Forms\Components\TextInput::make('video_url')
                            ->label('رابط الفيديو')
                            ->url()
                            ->maxLength(500)
                            ->visible(fn ($get) => $get('media_type') === 'video')
                            ->required(fn ($get) => $get('media_type') === 'video')
                            ->placeholder(function ($get) {
                                return match ($get('video_type')) {
                                    'youtube' => 'https://www.youtube.com/watch?v=...',
                                    'vimeo' => 'https://vimeo.com/...',
                                    'direct' => 'https://example.com/video.mp4',
                                    default => 'أدخل رابط الفيديو',
                                };
                            }),
                    ])
                    ->columns(1),

                Forms\Components\Section::make('الربط')
                    ->schema([
                        Forms\Components\Select::make('type')
                            ->label(__('filament.fields.type'))
                            ->options([
                                'movie' => __('filament.resources.movies.label'),
                                'series' => __('filament.resources.series.label'),
                                'category' => __('filament.resources.categories.label'),
                                'url' => 'رابط خارجي',
                            ])
                            ->reactive()
                            ->afterStateUpdated(fn ($state, callable $set) => [
                                $set('movie_id', null),
                                $set('series_id', null),
                                $set('category_id', null),
                                $set('url', null),
                            ]),
                        Forms\Components\Select::make('movie_id')
                            ->label(__('filament.resources.movies.label'))
                            ->relationship('movie', 'title')
                            ->searchable()
                            ->preload()
                            ->visible(fn ($get) => $get('type') === 'movie'),
                        Forms\Components\Select::make('series_id')
                            ->label(__('filament.resources.series.label'))
                            ->relationship('series', 'title')
                            ->searchable()
                            ->preload()
                            ->visible(fn ($get) => $get('type') === 'series'),
                        Forms\Components\Select::make('category_id')
                            ->label(__('filament.resources.categories.label'))
                            ->relationship('category', 'name')
                            ->searchable()
                            ->preload()
                            ->visible(fn ($get) => $get('type') === 'category'),
                        Forms\Components\TextInput::make('url')
                            ->label(__('filament.fields.url'))
                            ->url()
                            ->maxLength(255)
                            ->visible(fn ($get) => $get('type') === 'url'),
                        Forms\Components\TextInput::make('button_text')
                            ->label('نص الزر')
                            ->maxLength(255)
                            ->placeholder('شاهد الآن'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('الإعدادات')
                    ->schema([
                        Forms\Components\Toggle::make('is_active')
                            ->label(__('filament.fields.is_active'))
                            ->default(true),
                        Forms\Components\TextInput::make('order')
                            ->label(__('filament.fields.order'))
                            ->numeric()
                            ->default(0)
                            ->helperText('الترتيب (الأقل أولاً)'),
                    ])
                    ->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image')
                    ->label(__('filament.fields.poster'))
                    ->size(100),
                Tables\Columns\TextColumn::make('title')
                    ->label(__('filament.fields.title'))
                    ->searchable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('media_type')
                    ->label('نوع المحتوى')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'video' => '🎥 فيديو',
                        'image' => '🖼️ صورة',
                        default => '🖼️ صورة',
                    })
                    ->color(fn (?string $state): string => match ($state) {
                        'video' => 'danger',
                        'image' => 'success',
                        default => 'success',
                    }),
                Tables\Columns\TextColumn::make('video_type')
                    ->label('نوع الفيديو')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'youtube' => 'YouTube',
                        'vimeo' => 'Vimeo',
                        'direct' => 'مباشر',
                        default => '-',
                    })
                    ->color(fn (?string $state): string => match ($state) {
                        'youtube' => 'danger',
                        'vimeo' => 'info',
                        'direct' => 'warning',
                        default => 'gray',
                    })
                    ->toggleable(),
                Tables\Columns\TextColumn::make('type')
                    ->label(__('filament.fields.type'))
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'movie' => __('filament.resources.movies.label'),
                        'series' => __('filament.resources.series.label'),
                        'category' => __('filament.resources.categories.label'),
                        'url' => 'رابط خارجي',
                        default => $state ?? '-',
                    })
                    ->color(fn (?string $state): string => match ($state) {
                        'movie' => 'success',
                        'series' => 'info',
                        'category' => 'warning',
                        'url' => 'gray',
                        default => 'gray',
                    }),
                Tables\Columns\IconColumn::make('is_active')
                    ->label(__('filament.fields.is_active'))
                    ->boolean(),
                Tables\Columns\TextColumn::make('order')
                    ->label(__('filament.fields.order'))
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label(__('filament.fields.created_at'))
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label(__('filament.fields.type'))
                    ->options([
                        'movie' => __('filament.resources.movies.label'),
                        'series' => __('filament.resources.series.label'),
                        'category' => __('filament.resources.categories.label'),
                        'url' => 'رابط خارجي',
                    ]),
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label(__('filament.fields.is_active')),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('order', 'asc');
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSliders::route('/'),
            'create' => Pages\CreateSlider::route('/create'),
            'edit' => Pages\EditSlider::route('/{record}/edit'),
        ];
    }
}

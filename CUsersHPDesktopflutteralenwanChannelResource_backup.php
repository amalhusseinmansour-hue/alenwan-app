<?php

namespace App\Filament\Resources;

use App\Filament\Resources\ChannelResource\Pages;
use App\Filament\Resources\ChannelResource\RelationManagers;
use App\Models\Channel;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;
use Illuminate\Support\Str;

class ChannelResource extends Resource
{
    protected static ?string $model = Channel::class;

    protected static ?string $navigationIcon = 'heroicon-o-tv';

    public static function getNavigationGroup(): ?string
    {
        return __('filament.navigation.groups.content');
    }

    public static function getNavigationLabel(): string
    {
        return 'القنوات';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('المعلومات الأساسية')->schema([
                    Forms\Components\TextInput::make('name.ar')
                        ->label('اسم القناة (عربي)')
                        ->required()
                        ->live(onBlur: true)
                        ->afterStateUpdated(fn ($state, callable $set) => $set('slug', Str::slug($state))),

                    Forms\Components\TextInput::make('name.en')
                        ->label('اسم القناة (إنجليزي)')
                        ->required(),

                    Forms\Components\TextInput::make('slug')
                        ->label('المعرف')
                        ->required()
                        ->unique(ignoreRecord: true)
                        ->helperText('سيتم إنشاؤه تلقائياً من الاسم'),

                    Forms\Components\Textarea::make('description.ar')
                        ->label('الوصف (عربي)')
                        ->rows(3),

                    Forms\Components\Textarea::make('description.en')
                        ->label('الوصف (إنجليزي)')
                        ->rows(3),

                    Forms\Components\FileUpload::make('logo')
                        ->label('شعار القناة')
                        ->image()
                        ->directory('channels/logos')
                        ->imageEditor(),

                    Forms\Components\FileUpload::make('banner')
                        ->label('صورة الغلاف')
                        ->image()
                        ->directory('channels/banners')
                        ->imageEditor(),
                ])->columns(2),

                Forms\Components\Section::make('معلومات YouTube')->schema([
                    Forms\Components\TextInput::make('youtube_channel_id')
                        ->label('معرف قناة YouTube')
                        ->helperText('مثال: UCxxxxxxxxxxxxxx'),

                    Forms\Components\TextInput::make('youtube_channel_url')
                        ->label('رابط القناة على YouTube')
                        ->url()
                        ->helperText('مثال: https://www.youtube.com/@channelname'),

                    Forms\Components\TextInput::make('youtube_live_stream_id')
                        ->label('معرف البث المباشر')
                        ->helperText('معرف الفيديو للبث المباشر الحالي'),
                ])->columns(3)->collapsible(),

                Forms\Components\Section::make('معلومات Vimeo')->schema([
                    Forms\Components\TextInput::make('vimeo_channel_id')
                        ->label('معرف قناة Vimeo')
                        ->helperText('مثال: channels/xxxxxx'),

                    Forms\Components\TextInput::make('vimeo_channel_url')
                        ->label('رابط القناة على Vimeo')
                        ->url()
                        ->helperText('مثال: https://vimeo.com/channels/xxxxx'),

                    Forms\Components\TextInput::make('vimeo_live_event_id')
                        ->label('معرف الحدث المباشر')
                        ->helperText('معرف الحدث للبث المباشر الحالي'),
                ])->columns(3)->collapsible(),

                Forms\Components\Section::make('التصنيفات')->schema([
                    Forms\Components\Select::make('category_id')
                        ->label('التصنيف')
                        ->relationship('category', 'name')
                        ->searchable()
                        ->preload(),

                    Forms\Components\Select::make('language_id')
                        ->label('اللغة')
                        ->relationship('language', 'name')
                        ->searchable()
                        ->preload(),

                    Forms\Components\Select::make('platform')
                        ->label('المنصة')
                        ->options([
                            'youtube' => 'YouTube',
                            'vimeo' => 'Vimeo',
                            'both' => 'كلاهما',
                        ])
                        ->default('youtube')
                        ->required(),
                ])->columns(3),

                Forms\Components\Section::make('الإحصائيات')->schema([
                    Forms\Components\TextInput::make('subscribers_count')
                        ->label('عدد المشتركين')
                        ->numeric()
                        ->default(0),

                    Forms\Components\TextInput::make('views_count')
                        ->label('عدد المشاهدات')
                        ->numeric()
                        ->default(0),

                    Forms\Components\TextInput::make('videos_count')
                        ->label('عدد الفيديوهات')
                        ->numeric()
                        ->default(0),

                    Forms\Components\TextInput::make('order')
                        ->label('الترتيب')
                        ->numeric()
                        ->default(0),
                ])->columns(4),

                Forms\Components\Section::make('الإعدادات')->schema([
                    Forms\Components\Toggle::make('is_live')
                        ->label('بث مباشر حالياً')
                        ->default(false),

                    Forms\Components\Toggle::make('is_premium')
                        ->label('قناة مميزة')
                        ->default(false),

                    Forms\Components\Toggle::make('is_active')
                        ->label('نشطة')
                        ->default(true),

                    Forms\Components\Toggle::make('is_featured')
                        ->label('مميزة في الصفحة الرئيسية')
                        ->default(false),
                ])->columns(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('الشعار')
                    ->circular()
                    ->size(60),

                Tables\Columns\TextColumn::make('name')
                    ->label('اسم القناة')
                    ->searchable()
                    ->sortable()
                    ->limit(30)
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('platform')
                    ->label('المنصة')
                    ->badge()
                    ->color(fn ($state) => match($state) {
                        'youtube' => 'danger',
                        'vimeo' => 'info',
                        'both' => 'success',
                        default => 'gray',
                    })
                    ->icon(fn ($state) => match($state) {
                        'youtube' => 'heroicon-o-play',
                        'vimeo' => 'heroicon-o-film',
                        'both' => 'heroicon-o-video-camera',
                        default => null,
                    })
                    ->sortable(),

                Tables\Columns\IconColumn::make('is_live')
                    ->label('بث مباشر')
                    ->boolean()
                    ->trueIcon('heroicon-o-signal')
                    ->trueColor('danger')
                    ->falseIcon('heroicon-o-signal-slash')
                    ->falseColor('gray')
                    ->sortable(),

                Tables\Columns\TextColumn::make('subscribers_count')
                    ->label('المشتركين')
                    ->formatStateUsing(fn ($state) => number_format($state))
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('views_count')
                    ->label('المشاهدات')
                    ->formatStateUsing(fn ($state) => number_format($state))
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\TextColumn::make('category.name')
                    ->label('التصنيف')
                    ->badge()
                    ->color('info')
                    ->sortable()
                    ->toggleable(),

                Tables\Columns\IconColumn::make('is_premium')
                    ->label('مميزة')
                    ->boolean()
                    ->toggleable(),

                Tables\Columns\IconColumn::make('is_active')
                    ->label('نشطة')
                    ->boolean(),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('platform')
                    ->label('المنصة')
                    ->options([
                        'youtube' => 'YouTube',
                        'vimeo' => 'Vimeo',
                        'both' => 'كلاهما',
                    ])
                    ->multiple(),

                Tables\Filters\SelectFilter::make('category_id')
                    ->label('التصنيف')
                    ->relationship('category', 'name')
                    ->multiple()
                    ->preload(),

                Tables\Filters\TernaryFilter::make('is_live')
                    ->label('البث المباشر')
                    ->placeholder('الكل')
                    ->trueLabel('مباشر فقط')
                    ->falseLabel('غير مباشر'),

                Tables\Filters\TernaryFilter::make('is_premium')
                    ->label('المحتوى المميز')
                    ->placeholder('الكل')
                    ->trueLabel('مميز فقط')
                    ->falseLabel('عادي فقط'),

                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('الحالة')
                    ->placeholder('الكل')
                    ->trueLabel('نشط')
                    ->falseLabel('غير نشط'),
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
            RelationManagers\LiveStreamsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChannels::route('/'),
            'create' => Pages\CreateChannel::route('/create'),
            'edit' => Pages\EditChannel::route('/{record}/edit'),
        ];
    }
}

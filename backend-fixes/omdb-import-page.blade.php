<x-filament-panels::page>
    <div class="space-y-6">
        {{-- نموذج البحث والاستيراد --}}
        <x-filament::section>
            <x-slot name="heading">
                استيراد محتوى من IMDb
            </x-slot>

            <x-slot name="description">
                ابحث عن الأفلام والمسلسلات من قاعدة بيانات IMDb واستوردها مباشرة
            </x-slot>

            {{ $this->form }}

            <div class="mt-4 flex gap-3">
                <x-filament::button
                    wire:click="searchOmdb"
                    icon="heroicon-o-magnifying-glass"
                    color="primary"
                >
                    بحث في IMDb
                </x-filament::button>

                <x-filament::button
                    wire:click="bulkImport"
                    icon="heroicon-o-arrow-down-tray"
                    color="success"
                >
                    استيراد متعدد
                </x-filament::button>
            </div>
        </x-filament::section>

        {{-- نتائج البحث --}}
        @if(count($searchResults) > 0)
            <x-filament::section>
                <x-slot name="heading">
                    نتائج البحث ({{ count($searchResults) }})
                </x-slot>

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    @foreach($searchResults as $result)
                        <div class="border rounded-lg p-4 hover:shadow-lg transition">
                            <div class="flex gap-4">
                                @if($result['Poster'] !== 'N/A')
                                    <img
                                        src="{{ $result['Poster'] }}"
                                        alt="{{ $result['Title'] }}"
                                        class="w-24 h-36 object-cover rounded"
                                    >
                                @else
                                    <div class="w-24 h-36 bg-gray-200 rounded flex items-center justify-center">
                                        <x-heroicon-o-film class="w-12 h-12 text-gray-400" />
                                    </div>
                                @endif

                                <div class="flex-1">
                                    <h3 class="font-bold text-lg mb-1">{{ $result['Title'] }}</h3>
                                    <p class="text-sm text-gray-600 mb-2">
                                        {{ $result['Year'] }} • {{ ucfirst($result['Type']) }}
                                    </p>
                                    <p class="text-xs text-gray-500 mb-3">
                                        IMDb: {{ $result['imdbID'] }}
                                    </p>

                                    <div class="flex gap-2">
                                        <x-filament::button
                                            wire:click="importSingle('{{ $result['imdbID'] }}')"
                                            size="sm"
                                            color="success"
                                        >
                                            استيراد
                                        </x-filament::button>

                                        <x-filament::button
                                            wire:click="viewDetails('{{ $result['imdbID'] }}')"
                                            size="sm"
                                            color="gray"
                                            outlined
                                        >
                                            التفاصيل
                                        </x-filament::button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </x-filament::section>
        @endif

        {{-- تفاصيل المحتوى المحدد --}}
        @if($selectedDetails)
            <x-filament::section>
                <x-slot name="heading">
                    تفاصيل: {{ $selectedDetails['Title'] }}
                </x-slot>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    {{-- البوستر --}}
                    <div>
                        @if($selectedDetails['Poster'] !== 'N/A')
                            <img
                                src="{{ $selectedDetails['Poster'] }}"
                                alt="{{ $selectedDetails['Title'] }}"
                                class="w-full rounded-lg shadow-lg"
                            >
                        @else
                            <div class="w-full aspect-[2/3] bg-gray-200 rounded-lg flex items-center justify-center">
                                <x-heroicon-o-film class="w-24 h-24 text-gray-400" />
                            </div>
                        @endif
                    </div>

                    {{-- التفاصيل --}}
                    <div class="md:col-span-2 space-y-4">
                        <div>
                            <h2 class="text-2xl font-bold mb-2">{{ $selectedDetails['Title'] }}</h2>
                            <p class="text-gray-600">{{ $selectedDetails['Year'] }} • {{ $selectedDetails['Runtime'] ?? 'N/A' }}</p>
                        </div>

                        <div class="flex items-center gap-4">
                            <div class="bg-yellow-500 text-white px-3 py-1 rounded font-bold">
                                ⭐ {{ $selectedDetails['imdbRating'] ?? 'N/A' }}
                            </div>
                            <span class="text-sm text-gray-600">{{ $selectedDetails['imdbVotes'] ?? '0' }} votes</span>
                        </div>

                        <div>
                            <h3 class="font-bold mb-1">النوع:</h3>
                            <p>{{ $selectedDetails['Genre'] ?? 'N/A' }}</p>
                        </div>

                        <div>
                            <h3 class="font-bold mb-1">القصة:</h3>
                            <p class="text-gray-700">{{ $selectedDetails['Plot'] ?? 'لا يوجد وصف' }}</p>
                        </div>

                        <div>
                            <h3 class="font-bold mb-1">المخرج:</h3>
                            <p>{{ $selectedDetails['Director'] ?? 'N/A' }}</p>
                        </div>

                        <div>
                            <h3 class="font-bold mb-1">طاقم التمثيل:</h3>
                            <p>{{ $selectedDetails['Actors'] ?? 'N/A' }}</p>
                        </div>

                        @if(isset($selectedDetails['Awards']) && $selectedDetails['Awards'] !== 'N/A')
                            <div>
                                <h3 class="font-bold mb-1">الجوائز:</h3>
                                <p>{{ $selectedDetails['Awards'] }}</p>
                            </div>
                        @endif

                        <div class="pt-4">
                            <x-filament::button
                                wire:click="importSingle('{{ $selectedImdbId }}')"
                                color="success"
                                size="lg"
                            >
                                استيراد هذا المحتوى
                            </x-filament::button>

                            <x-filament::button
                                wire:click="$set('selectedDetails', null)"
                                color="gray"
                                size="lg"
                                class="ml-2"
                            >
                                إغلاق
                            </x-filament::button>
                        </div>
                    </div>
                </div>
            </x-filament::section>
        @endif

        {{-- معلومات إضافية --}}
        <x-filament::section>
            <x-slot name="heading">
                💡 نصائح الاستخدام
            </x-slot>

            <div class="prose prose-sm max-w-none">
                <ul>
                    <li><strong>البحث الفردي:</strong> ابحث عن فيلم أو مسلسل ثم اضغط "استيراد"</li>
                    <li><strong>الاستيراد المتعدد:</strong> ضع معرفات IMDb (مثل tt0468569) كل واحد في سطر منفصل</li>
                    <li><strong>IMDb ID:</strong> يمكنك العثور عليه في رابط الفيلم على IMDb (مثال: https://www.imdb.com/title/<strong>tt0468569</strong>/)</li>
                    <li><strong>ملاحظة:</strong> يجب إضافة روابط الفيديو والتريلر يدوياً بعد الاستيراد</li>
                    <li><strong>API Key:</strong> الحد الأقصى 1000 طلب يومياً</li>
                </ul>
            </div>
        </x-filament::section>
    </div>
</x-filament-panels::page>

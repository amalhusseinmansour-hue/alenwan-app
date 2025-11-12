import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SeriesDetailsPage extends StatefulWidget {
  final int seriesId;

  const SeriesDetailsPage({super.key, required this.seriesId});

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSeason = 1;

  // Demo Data
  final _demoSeries = {
    'id': 1,
    'title': 'Breaking Bad',
    'titleAr': 'بريكنج باد',
    'description': 'مدرس كيمياء في المدرسة الثانوية يتحول إلى صانع ميثامفيتامين بعد تشخيصه بالسرطان',
    'poster': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',
    'backdrop': 'https://image.tmdb.org/t/p/original/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
    'rating': 9.5,
    'year': 2008,
    'genres': ['جريمة', 'دراما', 'إثارة'],
    'cast': ['Bryan Cranston', 'Aaron Paul', 'Anna Gunn'],
  };

  final _demoSeasons = [
    {
      'season': 1,
      'episodes': [
        {'number': 1, 'title': 'Pilot', 'titleAr': 'الحلقة التجريبية', 'duration': '58 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 2, 'title': 'Cat\'s in the Bag', 'titleAr': 'القط في الحقيبة', 'duration': '48 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 3, 'title': 'And the Bag\'s in the River', 'titleAr': 'والحقيبة في النهر', 'duration': '48 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 4, 'title': 'Cancer Man', 'titleAr': 'رجل السرطان', 'duration': '48 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 5, 'title': 'Gray Matter', 'titleAr': 'المادة الرمادية', 'duration': '48 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
      ]
    },
    {
      'season': 2,
      'episodes': [
        {'number': 1, 'title': 'Seven Thirty-Seven', 'titleAr': 'سبعة وثلاثون', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 2, 'title': 'Grilled', 'titleAr': 'مشوي', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 3, 'title': 'Bit by a Dead Bee', 'titleAr': 'لدغة نحلة ميتة', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 4, 'title': 'Down', 'titleAr': 'للأسفل', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
      ]
    },
    {
      'season': 3,
      'episodes': [
        {'number': 1, 'title': 'No Más', 'titleAr': 'لا أكثر', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 2, 'title': 'Caballo Sin Nombre', 'titleAr': 'حصان بلا اسم', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
        {'number': 3, 'title': 'I.F.T.', 'titleAr': 'آي إف تي', 'duration': '47 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                _buildTabBar(),
                _buildContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _demoSeries['backdrop'] as String,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.error, color: Colors.white),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF121212).withValues(alpha: 0.7),
                    const Color(0xFF121212),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: _demoSeries['poster'] as String,
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _demoSeries['titleAr'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${_demoSeries['rating']}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_demoSeries['year']}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_demoSeries['genres'] as List<String>).map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE50914)),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFE50914),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'الحلقات'),
          Tab(text: 'التفاصيل'),
          Tab(text: 'المزيد'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SizedBox(
      height: 600,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEpisodesTab(),
          _buildDetailsTab(),
          _buildMoreTab(),
        ],
      ),
    );
  }

  Widget _buildEpisodesTab() {
    return Column(
      children: [
        _buildSeasonSelector(),
        Expanded(child: _buildEpisodesList()),
      ],
    );
  }

  Widget _buildSeasonSelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _demoSeasons.length,
        itemBuilder: (context, index) {
          final season = _demoSeasons[index];
          final seasonNumber = season['season'] as int;
          final isSelected = seasonNumber == _selectedSeason;

          return GestureDetector(
            onTap: () => setState(() => _selectedSeason = seasonNumber),
            child: Container(
              margin: const EdgeInsets.only(left: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE50914) : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'الموسم $seasonNumber',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodesList() {
    final selectedSeasonData = _demoSeasons.firstWhere(
      (s) => s['season'] == _selectedSeason,
      orElse: () => _demoSeasons[0],
    );
    final episodes = selectedSeasonData['episodes'] as List<Map<String, dynamic>>;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        return _buildEpisodeCard(episode);
      },
    );
  }

  Widget _buildEpisodeCard(Map<String, dynamic> episode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Play episode
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: episode['thumbnail'] as String,
                      width: 120,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحلقة ${episode['number']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode['titleAr'] as String,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode['duration'] as String,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'القصة',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _demoSeries['description'] as String,
            style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'طاقم التمثيل',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...(_demoSeries['cast'] as List<String>).map((actor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $actor',
                style: TextStyle(color: Colors.grey[300], fontSize: 16),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoreTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مسلسلات مشابهة',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(left: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: 'https://image.tmdb.org/t/p/w500/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

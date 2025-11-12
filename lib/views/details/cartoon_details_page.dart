import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartoonDetailsPage extends StatefulWidget {
  final int cartoonId;

  const CartoonDetailsPage({super.key, required this.cartoonId});

  @override
  State<CartoonDetailsPage> createState() => _CartoonDetailsPageState();
}

class _CartoonDetailsPageState extends State<CartoonDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSeason = 1;

  final _demoCartoon = {
    'id': 1,
    'title': 'SpongeBob SquarePants',
    'titleAr': 'سبونج بوب',
    'description': 'مغامرات إسفنجة البحر المرحة سبونج بوب وأصدقائه في قاع المحيط',
    'poster': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg',
    'backdrop': 'https://image.tmdb.org/t/p/original/qGYe61Fk3MYJtCDD0qBqIE7MaNP.jpg',
    'rating': 8.1,
    'year': 1999,
    'ageRating': '6+',
    'genres': ['كوميديا', 'مغامرات', 'عائلي'],
  };

  final _demoSeasons = [
    {
      'season': 1,
      'name': 'الموسم الأول',
      'episodes': [
        {'number': 1, 'title': 'Help Wanted', 'titleAr': 'مطلوب مساعدة', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
        {'number': 2, 'title': 'Reef Blower', 'titleAr': 'منفاخ الشعاب', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
        {'number': 3, 'title': 'Tea at the Treedome', 'titleAr': 'شاي في القبة', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
        {'number': 4, 'title': 'Bubblestand', 'titleAr': 'كشك الفقاعات', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
      ]
    },
    {
      'season': 2,
      'name': 'الموسم الثاني',
      'episodes': [
        {'number': 1, 'title': 'Your Shoe\'s Untied', 'titleAr': 'حذاؤك مفكوك', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
        {'number': 2, 'title': 'Squid\'s Day Off', 'titleAr': 'يوم إجازة سكويدوارد', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
        {'number': 3, 'title': 'Something Smells', 'titleAr': 'شيء ما يشم', 'duration': '11 دقيقة', 'thumbnail': 'https://image.tmdb.org/t/p/w500/gh4cZbhZxyTbgxQPxD0dOudNPTn.jpg'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              imageUrl: _demoCartoon['backdrop'] as String,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[900],
                child: const Center(child: CircularProgressIndicator()),
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
              imageUrl: _demoCartoon['poster'] as String,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _demoCartoon['ageRating'] as String,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _demoCartoon['titleAr'] as String,
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
                      '${_demoCartoon['rating']}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_demoCartoon['year']}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (_demoCartoon['genres'] as List<String>).map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF6B35)),
                      ),
                      child: Text(
                        genre,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
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
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        indicatorColor: const Color(0xFFFF6B35),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'الحلقات'),
          Tab(text: 'التفاصيل'),
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
                color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  season['name'] as String,
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
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {},
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
                ],
              ),
            ),
          ),
        );
      },
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
            _demoCartoon['description'] as String,
            style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

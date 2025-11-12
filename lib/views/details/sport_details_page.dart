import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SportDetailsPage extends StatefulWidget {
  final int sportId;

  const SportDetailsPage({super.key, required this.sportId});

  @override
  State<SportDetailsPage> createState() => _SportDetailsPageState();
}

class _SportDetailsPageState extends State<SportDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSeason = 1;

  // Demo Data
  final _demoSport = {
    'id': 1,
    'title': 'Premier League',
    'titleAr': 'الدوري الإنجليزي الممتاز',
    'description': 'أعلى مستوى في نظام دوري كرة القدم الإنجليزية، ويشمل 20 ناديًا',
    'poster': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
    'backdrop': 'https://image.tmdb.org/t/p/original/8Y43POKjjKDGI9MH89WW2PLHIMa.jpg',
    'rating': 9.0,
    'year': 2023,
    'category': 'كرة القدم',
    'country': 'إنجلترا',
  };

  final _demoSeasons = [
    {
      'season': 1,
      'name': 'موسم 2023-2024',
      'matches': [
        {
          'number': 1,
          'homeTeam': 'مانشستر سيتي',
          'awayTeam': 'ليفربول',
          'date': '15 أغسطس 2023',
          'time': '19:30',
          'stadium': 'الاتحاد',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': false,
        },
        {
          'number': 2,
          'homeTeam': 'آرسنال',
          'awayTeam': 'مانشستر يونايتد',
          'date': '20 أغسطس 2023',
          'time': '16:00',
          'stadium': 'الإمارات',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': true,
        },
        {
          'number': 3,
          'homeTeam': 'تشيلسي',
          'awayTeam': 'توتنهام',
          'date': '25 أغسطس 2023',
          'time': '14:30',
          'stadium': 'ستامفورد بريدج',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': false,
        },
        {
          'number': 4,
          'homeTeam': 'ليفربول',
          'awayTeam': 'نيوكاسل',
          'date': '1 سبتمبر 2023',
          'time': '20:00',
          'stadium': 'آنفيلد',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': false,
        },
      ]
    },
    {
      'season': 2,
      'name': 'موسم 2022-2023',
      'matches': [
        {
          'number': 1,
          'homeTeam': 'مانشستر سيتي',
          'awayTeam': 'آرسنال',
          'date': '10 أغسطس 2022',
          'time': '19:30',
          'stadium': 'الاتحاد',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': false,
        },
        {
          'number': 2,
          'homeTeam': 'ليفربول',
          'awayTeam': 'تشيلسي',
          'date': '15 أغسطس 2022',
          'time': '16:00',
          'stadium': 'آنفيلد',
          'thumbnail': 'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLjy3OAm5NUhbxtC.jpg',
          'isLive': false,
        },
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
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF121212),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _demoSport['backdrop'] as String,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _demoSport['titleAr'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                _demoSport['category'] as String,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                _demoSport['country'] as String,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _demoSport['description'] as String,
            style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
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
          Tab(text: 'المباريات'),
          Tab(text: 'الترتيب'),
          Tab(text: 'الإحصائيات'),
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
          _buildMatchesTab(),
          _buildStandingsTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Column(
      children: [
        _buildSeasonSelector(),
        Expanded(child: _buildMatchesList()),
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

  Widget _buildMatchesList() {
    final selectedSeasonData = _demoSeasons.firstWhere(
      (s) => s['season'] == _selectedSeason,
      orElse: () => _demoSeasons[0],
    );
    final matches = selectedSeasonData['matches'] as List<Map<String, dynamic>>;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final isLive = match['isLive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: isLive ? Border.all(color: const Color(0xFFE50914), width: 2) : null,
      ),
      child: InkWell(
        onTap: () {
          // Watch match
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE50914),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 6),
                      Text(
                        'مباشر الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      match['homeTeam'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match['time'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      match['awayTeam'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    match['date'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.stadium, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    match['stadium'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandingsTab() {
    final teams = [
      {'position': 1, 'team': 'مانشستر سيتي', 'points': 78, 'played': 30},
      {'position': 2, 'team': 'آرسنال', 'points': 75, 'played': 30},
      {'position': 3, 'team': 'ليفربول', 'points': 72, 'played': 30},
      {'position': 4, 'team': 'مانشستر يونايتد', 'points': 65, 'played': 30},
      {'position': 5, 'team': 'نيوكاسل', 'points': 60, 'played': 30},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: team['position'] as int <= 4
                      ? const Color(0xFFE50914)
                      : Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${team['position']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  team['team'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Text(
                '${team['points']} نقطة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard('أكثر اللاعبين تسجيلاً', 'Erling Haaland', '28 هدف'),
          const SizedBox(height: 12),
          _buildStatCard('أكثر اللاعبين صناعة', 'Kevin De Bruyne', '15 تمريرة حاسمة'),
          const SizedBox(height: 12),
          _buildStatCard('أفضل حارس مرمى', 'Alisson Becker', '15 شباك نظيفة'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String player, String stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                player,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                stat,
                style: const TextStyle(
                  color: Color(0xFFE50914),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
